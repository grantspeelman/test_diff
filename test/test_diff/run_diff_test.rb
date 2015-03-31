require File.expand_path '../../test_helper.rb', __FILE__

# dummy runner
class DummyRunner
  attr_reader :run_tests_value

  def run_tests(t)
    @run_tests_value = t
  end
end

# dummy version control class
class DummyVersionControl
  attr_accessor :changed_files
end

# dummy class for storage
class DummyStorage
  attr_accessor :select_tests

  def select_tests_for(*)
    select_tests
  end

  def test_info_for(_file)
  end
end

describe TestDiff::RunDiff do
  subject { TestDiff::RunDiff }
  let(:config) { TestDiff::Config }

  before :each do
    config.working_directory = 'test/fixture/minitest_sample'
    config.test_pattern = /mtest.rb\z/
    config.test_runner = DummyRunner.new
    config.version_control = DummyVersionControl.new
  end

  describe '#run' do
    it 'runs the tests that match test_pattern' do
      runner = subject.new('tests', nil, nil)
      config.version_control.changed_files = ['tests/example_mtest.rb']
      runner.run
      config.test_runner.run_tests_value.must_equal(
        ['tests/example_mtest.rb']
      )
    end

    it 'runs the tests that match the storage' do
      config.storage = DummyStorage.new
      runner = subject.new('tests', nil, nil)
      config.version_control.changed_files = ['lib/example.rb']
      test_info = TestDiff::TestInfo.new('tests/example_mtest.rb', 1)
      config.storage.select_tests = [test_info]
      runner.run
      config.test_runner.run_tests_value.must_equal(
        ['tests/example_mtest.rb']
      )
    end
  end
end
