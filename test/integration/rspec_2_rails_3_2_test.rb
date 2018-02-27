require File.expand_path '../../test_helper.rb', __FILE__

describe 'Rspec 2 & Rails 3.2' do
  # used to see which files it would run
  class TestTrapper
    attr_reader :files

    def run_tests(files)
      @files = files
    end
  end

  describe 'Results' do
    it 'checking results' do
      test_trapper = TestTrapper.new
      TestDiff::Config.test_runner = test_trapper
    end
  end
end
