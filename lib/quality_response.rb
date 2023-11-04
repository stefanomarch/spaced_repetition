# frozen_string_literal: true

class QualityResponse
  BLACKOUT_RESPONSE = 0
  INCORRECT_HARD_RESPONSE = 1
  INCORRECT_EASY_RESPONSE = 2
  DIFFICULT_RESPONSE = 3
  HESITATION_RESPONSE = 4
  PERFECT_RESPONSE = 5

  # Returns a human-readable string for the given response level
  def self.to_s(response_level)
    case response_level
    when PERFECT_RESPONSE
      'Perfect response - The correct answer was recalled without any hesitation.'
    when HESITATION_RESPONSE
      'Correct response after a hesitation.'
    when DIFFICULT_RESPONSE
      'Correct response recalled with serious difficulty.'
    when INCORRECT_EASY_RESPONSE
      'Incorrect response; where the correct one seemed easy to recall once reviewed.'
    when INCORRECT_HARD_RESPONSE
      'Incorrect response; the correct answer was very hard to recall.'
    when BLACKOUT_RESPONSE
      'Complete blackout, no recall at all.'
    else
      'Unknown response level.'
    end
  end
end
