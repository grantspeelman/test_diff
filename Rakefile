require 'bundler/gem_tasks'

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_spec.rb'
end

task default: %w(test build rubocop)
