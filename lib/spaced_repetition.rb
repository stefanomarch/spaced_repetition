# frozen_string_literal: true

require_relative 'spaced_repetition/version'
require_relative 'quality_response'
require 'active_support/core_ext/numeric/time'

# Documentation for SpacedRepetition Module
# This module implements a spaced repetition algorithm that can be included in any class
# to add spaced repetition learning capabilities. Spaced repetition is a study technique
# that involves increasing the time intervals between reviews of previously learned material
# to enhance memory retention and recall speed.
module SpacedRepetition
  VERSION = '2.0'
  MINUTES_PER_DAY = 1440.0

  def self.included(base)
    base.class_eval do
      attr_accessor :easiness_factor, :interval, :repetition_number,
                    :next_study_date, :learning_step

      def init_spaced_repetition
        self.easiness_factor = 2.5
        self.interval = 1
        self.repetition_number = 0
        self.learning_step = 0
        self.next_study_date = Time.now
        self
      end

      def update_spaced_repetition(quality_response)
        case quality_response
        when QualityResponse::BLACKOUT_RESPONSE
          # Complete blackout - repeat immediately (1 minute)
          self.interval = 1.0 / MINUTES_PER_DAY
          self.repetition_number = 0
          self.easiness_factor = [easiness_factor - 0.3, 1.3].max
        when QualityResponse::INCORRECT_HARD_RESPONSE
          # Hard incorrect - repeat very soon (3 minutes)
          self.interval = 3.0 / MINUTES_PER_DAY
          self.repetition_number = 0
          self.easiness_factor = [easiness_factor - 0.15, 1.3].max
        when QualityResponse::INCORRECT_EASY_RESPONSE
          # Easy incorrect - repeat after a short break (10 minutes)
          self.interval = 10.0 / MINUTES_PER_DAY
          self.repetition_number = 0
          self.easiness_factor = [easiness_factor - 0.1, 1.3].max
        when QualityResponse::DIFFICULT_RESPONSE
          # Difficult but correct
          self.interval = calculate_next_interval
          self.repetition_number += 1
          self.easiness_factor = [easiness_factor - 0.15, 1.3].max
        when QualityResponse::HESITATION_RESPONSE
          # Correct with hesitation
          self.interval = calculate_next_interval
          self.repetition_number += 1
        when QualityResponse::PERFECT_RESPONSE
          # Perfect response
          self.interval = calculate_next_interval
          self.repetition_number += 1
          self.easiness_factor = [easiness_factor + 0.15, 3.0].min
        end

        self.next_study_date = Time.now + interval.days
        self
      end

      private

      def calculate_next_interval
        case self.repetition_number
        when 0 then 1     # 1 day
        when 1 then 2     # 2 days
        when 2 then 4     # 4 days
        when 3 then 7     # 7 days
        when 4 then 11    # 11 days
        when 5 then 15    # 15 days
        when 6 then 20    # 20 days
        when 7 then 30    # 1 month
        else
          # For very well-known cards, grow interval by easiness factor
          # but ensure reasonable growth
          new_interval = (interval * easiness_factor).round
          if new_interval > 365
            365  # Cap at 1 year maximum
          else
            new_interval
          end
        end
      end
    end
  end
end
