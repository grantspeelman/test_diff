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
      add_changed_files
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
      groups_size = (@tests_to_run.length / groups_of.to_f).ceil
      @tests_to_run = @tests_to_run.slice(group.to_i * groups_size, groups_size) || []
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

    def add_changed_files
      _build_tests_to_run

      @tests_to_run.flatten!
      @tests_to_run.sort!
      @tests_to_run.uniq!
    end

    def _build_tests_to_run
      files = []
      Config.version_control.changed_files.each do |file_name|
        if Config.test_pattern.match(file_name)
          @tests_to_run << Config.storage.test_info_for(file_name)
        elsif !file_name.start_with?(@tests_folder)
          files << file_name
          _add_rails_view_spec(file_name)
        end
      end
      _add_calculated_tests(files)
    end

    def _add_calculated_tests(files)
      @tests_to_run << Config.storage.select_tests_for(files, tests_folder)
    end

    def _add_rails_view_spec(file_name)
      # try and find a matching view spec
      return unless file_name.include?('app/views')
      view_spec_name = file_name.gsub('app/views', "#{tests_folder}/views").gsub('.erb', '.erb_spec.rb')
      return unless  File.exist?(view_spec_name)
      @tests_to_run << view_spec_name
    end
  end
end
