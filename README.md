# TestDiff
[![Build Status](https://travis-ci.org/grantspeelman/test_diff.svg?branch=master)](https://travis-ci.org/grantspeelman/test_diff)

Gem that attempts to find the tests that are required to run for the changes you have made

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'test_diff'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install test_diff

## Usage

Building the test coverage index

    $ bundle exec test_diff build_coverage spec spec/spec_helper.rb
    $ git add test_diff_coverage
    $ git commit



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/test_diff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
