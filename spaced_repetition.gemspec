# frozen_string_literal: true

require_relative "lib/spaced_repetition/version"
# spaced_repetition.gemspec
Gem::Specification.new do |spec|
  spec.name          = "spaced_repetition"
  spec.version       = SpacedRepetition::VERSION
  spec.authors       = ["Stefano Marchetti"]
  spec.email         = ["marchettistefano930@gmai.com"]

  spec.summary       = %q{A mixin for spaced repetition scheduling}
  spec.description   = %q{This gem provides a mixin module that can be included in ActiveRecord models to add spaced repetition scheduling functionality.}
  spec.homepage      = "http://example.com/spaced_repetition"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org until 'allowed_push_host' is set in your '.gemspec' file
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(CHANGELOG\.md|README\.md|lib/.*|spec/.*|bin/.*)$}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"

  # Specify the gem's dependencies here
  spec.add_dependency "activerecord", ">= 5.0", "< 7.0"
end

