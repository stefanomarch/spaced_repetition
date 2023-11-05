# Spaced Repetition Algorithm Documentation

This document explains the underlying algorithm used in the SpacedRepetition module for Ruby. The algorithm is designed to optimize learning by calculating the best time intervals for review based on user performance.

## Overview

Spaced repetition leverages the psychological spacing effect to enhance efficiency in learning. The algorithm determines the optimal interval for reviewing information to ensure that the memory trace remains strong and that recall likelihood increases over time.

## Easiness Factor

The easiness factor (EF) plays a crucial role in determining the intervals between reviews. It starts at 2.5 by default and adjusts after every recall attempt as follows:

```ruby
new_ef = old_ef - 0.8 + (0.28 * quality_response) - (0.02 * quality_response**2)
new_ef = [new_ef, MINIMUM_EFACTOR].max
```

Where quality_response is a score from 0 to 5 indicating the quality of recall.

## Interval Calculation
The intervals are calculated differently depending on the number of times an item has been reviewed (repetition_number):

First Repetition: 1 day
Second Repetition: 4 days
Subsequent Repetitions: previous_interval * EF
The repetition number is increased by one after each recall, except when the recall is poor, in which case the repetition number is reset to zero, and the item is scheduled for quick review.

## Quick Reviews
Quick reviews are scheduled in cases of poor recall quality, with the following rules applied:

If the response is incorrect but the user found it easy, the next review is scheduled in 1 hour.
For other poor recalls, the review is scheduled in 5 minutes.
## Stopping Condition
To prevent intervals from becoming counterproductively long, a stopping condition is implemented. If the interval calculated exceeds a threshold (e.g., 4 days), the interval stops increasing regardless of the EF, and the current interval is maintained for subsequent reviews.

## Implementation in Ruby
The algorithm is implemented within a module to be included in Ruby classes that represent items to be learned. It relies on ActiveSupport's time extensions for interval calculation and rounds intervals to the nearest day.

The module provides init_spaced_repetition to initialize repetition data and update_spaced_repetition to update these based on user performance.

## Conclusion
This algorithm is a Ruby-centric implementation of the widely researched spaced repetition model for learning. It can be integrated into any study tool or application to help users learn more effectively by spacing their review of material according to their personal recall abilities and performance history.

