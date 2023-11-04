# frozen_string_literal: true

require_relative "spaced_repetition/version"

module SpacedRepetition
  class Error < StandardError; end

  # When this module is included, it adds the following methods to the base class
  def self.included(base)
    base.class_eval do
      unless method_defined?(:easiness_factor)
        attr_accessor :easiness_factor, :quality_response, :repetition_number, :interval, :next_study_date
      end

      # Initialize the spaced repetition data on an object
      def init_spaced_repetition(e_factor: 2.5, interval: 1, repetition_num: 0)
        self.easiness_factor = e_factor
        self.interval = interval
        self.repetition_number = repetition_num
        self.next_study_date = Time.now + self.interval.days
      end

      # Updates the object with spaced repetition data.
      def update_spaced_repetition(quality_response)
        self.easiness_factor ||= 2.5
        self.repetition_number ||= 0
        self.interval ||= 1

        if quality_response < 3
          # Reset interval if the response quality is below 3
          self.repetition_number = 0
          self.interval = 1
        else
          # Calculate new easiness factor
          new_e_factor = self.easiness_factor - 0.8 + 0.28 * quality_response - 0.02 * quality_response ** 2
          self.easiness_factor = [new_e_factor, 1.3].max

          # Calculate new interval
          self.interval = case self.repetition_number
                          when 0 then 1
                          when 1 then 6
                          else (self.interval * self.easiness_factor).round
                          end
          self.repetition_number += 1
        end

        self.next_study_date = Time.now + self.interval.days
        self
      end
    end
  end
end
