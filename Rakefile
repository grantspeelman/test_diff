require 'bundler/gem_tasks'

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task default: %w[rubocop test spec build]
