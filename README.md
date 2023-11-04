# SpacedRepetition

Welcome to the SpacedRepetition gem! This gem provides a mixin module that adds spaced repetition scheduling to your Ruby on Rails models, particularly useful for flashcard-type applications where items need to be reviewed at increasing intervals.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spaced_repetition'
```

And then execute:

```ruby
$ bundle install
```

Or install it yourself as:

```ruby
$ gem install spaced_repetition
```

## Usage

After installing the gem, you can add it to a model like so:

```ruby
class Flashcard < ApplicationRecord
  include SpacedRepetition
end
```

Make sure your Flashcard model has the following attributes:

- **easiness_factor**: A float that determines the ease of recalling the flashcard.
- **quality_response**: An integer that represents the user's recall quality, typically from 0 (complete blackout) to 5 (perfect response).
- **repetition_number**: An integer counting the number of times the flashcard has been reviewed.
- **interval**: The current interval for the next review in days.
- **next_study_dat**e: A DateTime for the next scheduled review of the flashcard.

Here's how you update the repetition data after a user reviews a flashcard:
```ruby
@flashcard = Flashcard.find(params[:id])
@flashcard.update_spaced_repetition(params[:quality_response])
```

This will calculate the new easiness_factor, interval, and next_study_date based on the provided quality_response.

## Api Example

```ruby
# POST /api/v1/flashcards/:id/review
def review
  flashcard = Flashcard.find(params[:id])
  flashcard.update_spaced_repetition(params[:quality_response])
  render json: flashcard
end
```
After checking out the repo, run bin/setup to install dependencies. You can also run bin/console for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run bundle exec rake install. To release a new version, update the version number in version.rb, and then run bundle exec rake release, which will create a git tag for the version, push git commits and tags, and push the .gem file to rubygems.org.

## Contributing
Bug reports and pull requests are welcome on GitHub at [repository URL]. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

## License
The gem is available as open source under the terms of the MIT License.

## Code of Conduct
Everyone interacting in the SpacedRepetition project’s codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](link to code of conduct).