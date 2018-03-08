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
      skip
      TestDiff::Config.reset

      test_trapper = TestTrapper.new
      TestDiff::Config.test_runner = test_trapper

      Dir.chdir 'test/fixture/rspec_2_rails_3_2' do
        current_tracking_file = TestDiff::Config.current_tracking_file
        TestDiff::Config.version_control =
          TestDiff::VersionControl::Git.new('../../../', File.read(current_tracking_file))
        TestDiff::RunDiff.new('spec', nil, '0').run
      end

      test_trapper.files.must_equal([])
    end
  end
end
