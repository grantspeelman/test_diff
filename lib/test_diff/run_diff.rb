# TestDiff module
module TestDiff
  # Class used to calculate the tests than need to be run
  class RunDiff
    attr_reader :tests_folder, :groups_of, :group

    def initialize(tests_folder, groups_of, group)
      @tests_folder = tests_folder
      @tests_to_run = []
      @groups_of = groups_of
      @group = group
    end

    def run
      RunableTests.new(@tests_to_run, @tests_folder).add_changed_files
      remove_tests_that_do_not_exist
      remove_tests_in_wrong_folder
      select_test_group
      run_test_group
    end

    private

    def run_test_group
      Config.test_runner.run_tests(@tests_to_run.map(&:filename))
    end

    def select_test_group
      return unless groups_of
      new_set_of_tests_to_run = []
      @tests_to_run.each_with_index do |test, i|
        new_set_of_tests_to_run << test if i % groups_of.to_i == group.to_i
      end
      @tests_to_run = new_set_of_tests_to_run
    end

    def remove_tests_that_do_not_exist
      @tests_to_run.delete_if do |s|
        !File.exist?("#{Config.working_directory}/#{s.filename}")
      end
    end

    def remove_tests_in_wrong_folder
      @tests_to_run.delete_if do |s|
        !s.filename.start_with?("#{tests_folder}/")
      end
    end
  end
end
