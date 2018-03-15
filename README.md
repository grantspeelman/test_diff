# TestDiff
[![Build Status](https://travis-ci.org/grantspeelman/test_diff.svg?branch=master)](https://travis-ci.org/grantspeelman/test_diff)

Gem that attempts to find the tests that are required to run for the changes you have made.

## Project requirements

* RSpec 2+
* project tracked with git

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'test_diff', group: :test
```

And then execute:

    $ bundle

## Rails Setup

Suggest to disabled `eager_load` in `config/environments/test.rb` based on `ENV['TEST_DIFF_COVERAGE']`
EG:

```ruby
config.eager_load = ENV['TEST_DIFF_COVERAGE'].blank?
```

Also make sure to disable `simple_cov` if you use it when `ENV['TEST_DIFF_COVERAGE']` is set
EG:

```ruby
unless ENV['TEST_DIFF_COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
end
```

## Usage

Building the test coverage index

    $ test_diff build_coverage spec spec/spec_helper.rb
    $ # part here to upload test_diff_coverage to a shared space, ie aws

Running a test difference

    $ # part here to download test_diff_coverage from shared space, ie aws
    $ test_diff rspec

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/test_diff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
