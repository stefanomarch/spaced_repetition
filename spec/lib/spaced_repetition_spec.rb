# frozen_string_literal: true

# spec/lib/spaced_repetition_spec.rb
require 'spec_helper'
require 'spaced_repetition'
require 'quality_response'
require 'active_support/core_ext/numeric/time'
require 'byebug'

class Flashcard
  include SpacedRepetition
end

RSpec.describe SpacedRepetition do
  let(:flashcard) { Flashcard.new }

  before do
    flashcard.init_spaced_repetition
  end

  describe 'SpacedRepetition#init_spaced_repetition' do
    it 'sets the easiness factor to 2.5' do
      expect(flashcard.easiness_factor).to eq(2.5)
    end

    it 'sets the interval to 1' do
      expect(flashcard.interval).to eq(1)
    end

    it 'sets the repetition number to 0' do
      expect(flashcard.repetition_number).to eq(0)
    end

    it 'sets the next study date to the current date and time' do
      expect(flashcard.next_study_date).to be_within(1.day).of(Time.now)
    end
  end

  describe 'SpacedRepetition#update_spaced_repetition when easiness factor is blackout' do
    context 'when the quality response is a complete blackout, it means that is the molst difficult' do
      before { flashcard.update_spaced_repetition(QualityResponse::BLACKOUT_RESPONSE) }

      it 'let you repeat the card 5 minutes later' do
        expect(flashcard.next_study_date).to be_within(5.minutes).of(Time.now)
      end

      it 'reinitialize the repetition number to 0' do
        expect(flashcard.repetition_number).to eq(0)
      end
    end
  end

  describe 'SpacedRepetition#update_spaced_repetition' do
    context 'when the quality response is incorrect and hard' do
      before { flashcard.update_spaced_repetition(QualityResponse::INCORRECT_HARD_RESPONSE) }
      it 'let you repeat the card 5 minutes later' do
        expect(flashcard.next_study_date).to be_within(5.minutes).of(Time.now)
      end

      it 'reinitialize the repetition number to 0' do
        expect(flashcard.repetition_number).to eq(0)
      end
    end
  end

  describe 'SpacedRepetition#update_spaced_repetition' do
    context 'when the quality response is incorrect but seemed easy after review' do
      before { flashcard.update_spaced_repetition(QualityResponse::INCORRECT_EASY_RESPONSE) }
      it 'let you repeat the card q hour later' do
        expect(flashcard.next_study_date).to be_within(1.hour).of(Time.now)
      end

      it 'reinitialize the repetition number to 0' do
        expect(flashcard.repetition_number).to eq(0)
      end
    end
  end

  # -------------- Spaced repetition when correct answers DIFFICULT_RESPONSE --------------
  describe 'SpacedRepetition#update_spaced_repetition' do
    context 'when the response is correct, with serious difficulty, for the first time' do
      before { flashcard.update_spaced_repetition(QualityResponse::DIFFICULT_RESPONSE) }
      it 'decreases the easiness factor to less than 2.5' do
        expect(flashcard.easiness_factor).to be < 2.5
      end

      it 'let you repeat the card 1 day later' do
        expect(flashcard.next_study_date).to be_within(1.day).of(Time.now)
      end

      it 'increases the repetition number by 1' do
        expect(flashcard.repetition_number).to eq(1)
      end
    end

    context 'when the response is correct, with serious difficulty, for the second time' do
      before do
        2.times { flashcard.update_spaced_repetition(QualityResponse::DIFFICULT_RESPONSE) }
      end

      it 'descreases the easiness factor to less than the previous time' do
        previous = 2.36
        expect(flashcard.easiness_factor).to be < previous
      end
      it 'let you repeat the card 4 days later' do
        expect(flashcard.next_study_date).to be_within(4.days).of(Time.now)
      end

      it 'increases the repetition number by 1' do
        expect(flashcard.repetition_number).to eq(2)
      end
    end

    context 'when the response is correct, with serious difficulty, for the third time' do
      before do
        3.times { flashcard.update_spaced_repetition(QualityResponse::DIFFICULT_RESPONSE) }
      end

      it 'descreases the easiness factor to less than the previous time' do
        previous = 2.21
        expect(flashcard.easiness_factor).to be < previous
      end

      it 'let you repeat the card to a mathematical time' do
        expect(flashcard.next_study_date).to be_within(9.days).of(Time.now)
      end

      it 'increases the repetition number by 1' do
        expect(flashcard.repetition_number).to eq(3)
      end
    end

    context 'when the response is correct, with serious difficulty, for the 4th time' do
      before do
        4.times { flashcard.update_spaced_repetition(QualityResponse::DIFFICULT_RESPONSE) }
      end

      it 'descreases the easiness factor to less than the previous time' do
        previous = 2.21
        expect(flashcard.easiness_factor).to be < previous
      end

      it 'let you repeat the card to incremental time' do
        expect(flashcard.next_study_date).to be_within(16.days).of(Time.now)
      end

      it 'increases the repetition number by 1' do
        expect(flashcard.repetition_number).to eq(4)
      end

      describe 'SpacedRepetition#update_spaced_repetition' do
        context 'when the response is correct, with serious difficulty, for the 5th time' do
          before do
            5.times { flashcard.update_spaced_repetition(QualityResponse::DIFFICULT_RESPONSE) }
          end

          it 'the interval blocks will remain the same of the previos time , you will repeat every 16 days' do
            expect(flashcard.next_study_date).to be_within(16.days).of(Time.now)
          end

          it 'increases the repetition number by 1' do
            expect(flashcard.repetition_number).to eq(5)
          end
        end
      end
    end

    context 'when the response is correct after hesitation' do
      # Test for interval and easiness factor adjustments for a hesitated correct response
    end

    context 'when the response is perfect' do
      # Test for interval and easiness factor adjustments for a perfect response
    end

    context 'with varying repetition numbers' do
      context 'when the item is studied for the first time' do
        # Test for interval after the first study session
      end

      context 'when the item is studied for the second time' do
        # Test for interval after the second study session
      end

      context 'when the item is reviewed for the third time and beyond' do
        # Iterative tests for each subsequent review, asserting increased intervals based on the easiness factor
      end
    end

    context 'when the easiness factor reaches the minimum threshold' do
      # Test to ensure the easiness factor does not drop below the minimum threshold
    end

    context 'when incorrect responses follow correct responses' do
      # Test for the effect of a mix of correct and incorrect responses on the easiness factor and interval
    end
  end
end
