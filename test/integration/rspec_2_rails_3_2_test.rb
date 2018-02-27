require File.expand_path '../../test_helper.rb', __FILE__

describe 'Rspec 2 & Rails 3.2' do
  # used to see which files it would run
  class TestTrapper
    attr_reader :files

    def run_tests(files)
      @files = files
    end
  end

  describe '#run' do
    it 'runs the tests that match test_pattern' do
      Dir.chdir('test/fixture/rspec_2_rails_3_2') do
        assert system('bundle install')
        assert system('bundle exec test_diff build_coverage spec spec/spec_helper.rb')
      end

      test_trapper = TestTrapper.new
      TestDiff::Config.test_runner = test_trapper
    end
  end
end
