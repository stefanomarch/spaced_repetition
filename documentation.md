# Documentation of Spaced Repetition Algorithm

## Introduction

This detailed documentation covers the implementation of a spaced repetition algorithm within a Ruby module. The goal of spaced repetition is to enhance memory retention by using increasing intervals of time between reviews of the studied material, based on the cognitive science principle that our brains learn more efficiently when repetition is spread out over time.

## Components of the Algorithm

### Easiness Factor (EF)

- **Role**: Modifies the gap between study sessions to tailor to the individual's performance.
- **Initial Value**: Traditionally set at 2.5 for new items.
- **Adjustment**: Decreases with each difficult recall, increases with easier recalls to a smaller degree, never falling below a minimum value to prevent intervals from becoming too short.

### Quality Response

- **Definition**: A numeric score that reflects the quality of recall, ranging from 0 (complete blackout) to 5 (perfect recall).
- **Usage**: Determines adjustments to the EF and the interval length for the next review.

### Repetition Number

- **Role**: Tracks the number of successful reviews for an item.
- **Reset Condition**: Resets to zero after a poor recall requiring a quick review.
- **Incrementation**: Increases by one after each successful review.

### Interval Calculation

- **First Review**: Fixed at one day after the initial learning session.
- **Second Review**: Set to a longer fixed interval, typically 4 days.
- **Subsequent Reviews**: Multiplied by the EF to progressively extend the interval between reviews.

### Quick Review Scheduling

- **For Incorrect Easy Responses**: Scheduled one hour after the initial attempt.
- **For Other Poor Recalls**: Scheduled five minutes after the attempt.

## Algorithm Pseudocode

```ruby
def init_spaced_repetition(e_factor: default_ef, interval: default_interval, repetition_num: default_repetition)
  @easiness_factor, @interval, @repetition_number = e_factor, interval, repetition_num
  @next_study_date = current_time + interval
end

def update_spaced_repetition(quality_response)
  if quality_response < threshold_difficult_response
    schedule_quick_review(quality_response)
  else
    adjust_schedule_for_successful_review(quality_response)
  end
  @next_study_date = current_time + @interval
end

private

def schedule_quick_review(quality_response)
  reset_repetition_number
  calculate_quick_review_interval(quality_response)
end

def adjust_schedule_for_successful_review(quality_response)
  calculate_new_easiness_factor(quality_response)
  calculate_new_interval
  increment_repetition_number
end

def calculate_new_easiness_factor(quality_response)
  # EF formula here, ensuring it doesn't go below the minimum value
end

def calculate_new_interval
  if @repetition_number == 0 then return first_interval
  if @repetition_number == 1 then return second_interval
  increase_interval_based_on_ef
end

def increase_interval_based_on_ef
  # Interval increase logic with maximum cap if needed
end
