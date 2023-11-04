# frozen_string_literal: true

require_relative 'spaced_repetition/version'
require_relative 'quality_response'
require 'active_support/core_ext/numeric/time'
require 'byebug'

# Documentation for SpacedRepetition Module
# This module implements a spaced repetition algorithm that can be included in any class
# to add spaced repetition learning capabilities. Spaced repetition is a study technique
# that involves increasing the time intervals between reviews of previously learned material
# to enhance memory retention and recall speed.
module SpacedRepetition
  class Error < StandardError; end

  MINUTES_PER_DAY = 1440.0
  FIRST_REPETITION_INTERVAL_DAYS = 1
  SECOND_REPETITION_INTERVAL_DAYS = 4
  MINIMUM_EFACTOR = 1.3 # The minimum value for the easiness factor.

  # When included in a class, this module provides methods for initializing and updating
  # objects based on spaced repetition learning principles.

  # This method initializes the spaced repetition data for an object with default or specified values.
  # @param easiness_factor [Float] the easiness factor, which controls the separation of repetition intervals.
  #                         Starting default is 2.5, and it adjusts based on recall quality in future repetitions.
  # @param interval [Integer] the interval, in days, until the next repetition should occur.
  #                           The starting default is 1, which is the minimum interval used.
  # @param repetition_number [Integer] the count of how many times an item has been reviewed.
  #                                 It begins at 0 and increments with each review session.
  # The `init_spaced_repetition` method sets up these attributes and calculates the next study date
  # by adding the interval to the current date and time. It's crucial for starting the process of
  # spaced repetition with any learning item.

  def self.included(base)
    base.class_eval do
      unless method_defined?(:easiness_factor)
        attr_accessor :easiness_factor, :interval, :repetition_number, :next_study_date
      end

      # Initializes the object for spaced repetition with default or specified values.
      def init_spaced_repetition(e_factor: 2.5, interval: FIRST_REPETITION_INTERVAL_DAYS, repetition_num: 0)
        self.easiness_factor = e_factor # The 'easiness factor' adjusts the spacing of reviews.
        self.interval = interval # 'interval' is the gap (in days) before the next review.
        self.repetition_number = repetition_num # 'repetition number' is how many times the item has been reviewed.
        self.next_study_date = Time.now + self.interval.days # 'next study date' is when the item should next be reviewed.
      end

      # Updates the spaced repetition attributes based on the quality of the response.
      def update_spaced_repetition(quality_response)
        # Set default values if not previously initialized.
        self.easiness_factor ||= 2.5
        self.repetition_number ||= 0
        self.interval ||= FIRST_REPETITION_INTERVAL_DAYS

        # if the quality response is in the group of instant repetition
        if quality_response < QualityResponse::DIFFICULT_RESPONSE
          schedule_quick_review(quality_response)
        else
          # Adjust intervals and factor for good recall quality.
          adjust_schedule_for_successful_review(quality_response)
        end

        # Update the next study date based on new interval.
        self.next_study_date = Time.now + self.interval.days
        self
      end

      private

      # Resets the repetition schedule for items with poor recall quality.
      def schedule_quick_review(quality_response)
        self.repetition_number = 0 # Reinitialize the repetition count.
        self.interval = if quality_response == QualityResponse::INCORRECT_EASY_RESPONSE
                          # repeat after 1 hour
                          60 / MINUTES_PER_DAY
                        else
                          # repeat after 5 minutes
                          5 / MINUTES_PER_DAY
                        end
      end

      # Adjusts the learning schedule based on successful recall.
      def adjust_schedule_for_successful_review(quality_response)
        self.easiness_factor = [calculate_new_easiness_factor(quality_response), MINIMUM_EFACTOR].max # Ensure the e-factor is not below the minimum.
        self.interval = calculate_new_interval # Calculate and set the new interval.
        self.repetition_number += 1 # Increment the count of review sessions.
      end

      # Calculates a new easiness factor based on the quality response score.
      def calculate_new_easiness_factor(quality_response)
        self.easiness_factor - 0.8 + (0.28 * quality_response) - (0.02 * quality_response**2)
      end

      # Determines the next interval based on the current interval, easiness factor, and repetition number.
      def calculate_new_interval
        case self.repetition_number
        when 0 then FIRST_REPETITION_INTERVAL_DAYS
        when 1 then SECOND_REPETITION_INTERVAL_DAYS
        else
          if self.interval <= 4
            (self.interval * self.easiness_factor).round
          else
            self.interval
          end
        end
      end
    end
  end
end
