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
  # -------------- Init spaced repetition  --------------
  describe 'SpacedRepetition#init_spaced_repetition' do
    it 'sets initial values' do
      expect(flashcard.easiness_factor).to eq(2.5)
      expect(flashcard.interval).to eq(1)
      expect(flashcard.repetition_number).to eq(0)
      expect(flashcard.next_study_date).to be_within(1.second).of(Time.now)
    end
  end

  # -------------- Test one example for each response type --------------
  describe 'SpacedRepetition#update_spaced_repetition' do
    context 'when response is BLACKOUT (0)' do
      before { flashcard.update_spaced_repetition(QualityResponse::BLACKOUT_RESPONSE) }

      it 'schedules immediate review (1 minute)' do
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 1.minute)
      end

      it 'resets repetition number and decreases ease factor significantly' do
        expect(flashcard.repetition_number).to eq(0)
        expect(flashcard.easiness_factor).to eq(2.2) # 2.5 - 0.3
      end
    end

    context 'when response is INCORRECT_HARD (1)' do
      before { flashcard.update_spaced_repetition(QualityResponse::INCORRECT_HARD_RESPONSE) }

      it 'schedules very quick review (3 minutes)' do
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 3.minutes)
      end

      it 'resets repetition number and decreases ease factor' do
        expect(flashcard.repetition_number).to eq(0)
        expect(flashcard.easiness_factor).to eq(2.35) # 2.5 - 0.15
      end
    end

    context 'when response is INCORRECT_EASY (2)' do
      before { flashcard.update_spaced_repetition(QualityResponse::INCORRECT_EASY_RESPONSE) }

      it 'schedules short review (10 minutes)' do
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 10.minutes)
      end

      it 'resets repetition number and slightly decreases ease factor' do
        expect(flashcard.repetition_number).to eq(0)
        expect(flashcard.easiness_factor).to eq(2.4) # 2.5 - 0.1
      end
    end

    context 'when response is DIFFICULT (3)' do
      before { flashcard.update_spaced_repetition(QualityResponse::DIFFICULT_RESPONSE) }

      it 'schedules next review with normal progression' do
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 1.day)
      end

      it 'increases repetition number and decreases ease factor' do
        expect(flashcard.repetition_number).to eq(1)
        expect(flashcard.easiness_factor).to eq(2.35) # 2.5 - 0.15
      end
    end

    context 'when response is HESITATION (4)' do
      before { flashcard.update_spaced_repetition(QualityResponse::HESITATION_RESPONSE) }

      it 'schedules next review with normal progression' do
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 1.day)
      end

      it 'increases repetition number and maintains ease factor' do
        expect(flashcard.repetition_number).to eq(1)
        expect(flashcard.easiness_factor).to eq(2.5) # Unchanged
      end
    end

    context 'when response is PERFECT (5)' do
      before { flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE) }

      it 'schedules next review with normal progression' do
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 1.day)
      end

      it 'increases repetition number and increases ease factor' do
        expect(flashcard.repetition_number).to eq(1)
        expect(flashcard.easiness_factor).to eq(2.65) # 2.5 + 0.15
      end
    end

    context 'Learning a new card' do
      it 'shows how review timing changes with perfect answers' do
        # When you first learn a card and get it right...
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(1) # "See you tomorrow!"

        # Get it right again...
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(2) # "See you in 2 days!"

        # Keep getting it right...
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(4) # "See you in 4 days!"

        # You're doing great!
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(7) # "See you in a week!"

        # You really know this!
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(11) # "See you in 11 days!"

        # You're mastering it!
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(15) # "See you in 15 days!"

        # Almost memorized!
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(20) # "See you in 20 days!"

        # You've got it!
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(30) # "See you in a month!"
      end

      it 'helps you when you make a mistake' do
        # First, let's learn it well...
        4.times { flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE) }
        expect(flashcard.interval).to eq(7) # "Was showing every week"

        # Oops! You forgot it completely!
        flashcard.update_spaced_repetition(QualityResponse::BLACKOUT_RESPONSE)
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 1.minute)
        # "Let's try again in 1 minute!"

        # Now you remember it
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(1) # "Back to daily practice"

        # Keep practicing...
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(2) # "Getting better again!"
      end

      it 'never makes you wait too long between reviews' do
        # First, get to monthly reviews
        8.times { flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE) }
        expect(flashcard.interval).to eq(30) # "Showing monthly"

        # Keep getting it perfect
        5.times { flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE) }

        # Even if you're perfect, wait at most a year
        expect(flashcard.interval).to eq(365) # "Maximum is once per year!"
      end

      it 'gives you extra practice when you need it' do
        # Learn it until weekly reviews
        4.times { flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE) }
        expect(flashcard.interval).to eq(7) # "Was showing weekly"

        # Had trouble remembering...
        flashcard.update_spaced_repetition(QualityResponse::INCORRECT_HARD_RESPONSE)
        expect(flashcard.next_study_date).to be_within(2.seconds).of(Time.now + 3.minutes)
        # "Quick review in 3 minutes!"

        # Now you got it!
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(1) # "Back to daily practice"

        # Keep it up!
        flashcard.update_spaced_repetition(QualityResponse::PERFECT_RESPONSE)
        expect(flashcard.interval).to eq(2)    # "Getting better again!"
      end
    end
  end
end
