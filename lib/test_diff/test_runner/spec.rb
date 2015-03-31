require 'git'
# TestDiff module
module TestDiff
  # module for test runners
  module TestRunner
    # class to run rspec tests
    class Spec
      def run_tests(specs)
        if specs.any?
          puts "bundle exec spec #{specs.join(' ')}"
          exec "bundle exec spec #{specs.join(' ')}"
        else
          puts 'no specs found to run'
        end
      end
    end
  end
end
