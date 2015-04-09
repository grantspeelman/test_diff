# TestDiff module
module TestDiff
  # class used to find tests that are runable
  class RunableTests
    def self.add_all(spec_folder, list, continue = false)
      if File.file?(spec_folder)
        list << spec_folder
      else
        Dir["#{spec_folder}/**/*_spec.rb"].each do |spec_name|
          has_no_data = Config.storage.get(spec_name).empty?
          list << spec_name if has_no_data || !continue
        end
      end
    end

    attr_reader :tests_folder

    def initialize(list_to_add_to, tests_folder)
      @tests_to_run = list_to_add_to
      @tests_folder = tests_folder
    end

    def add_changed_files
      _build_tests_to_run

      @tests_to_run.flatten!
      @tests_to_run.sort!
      @tests_to_run.uniq!(&:filename)
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
      return unless File.exist?("#{Config.working_directory}/#{view_spec_name}")
      @tests_to_run << Config.storage.test_info_for(view_spec_name)
    end
  end
end
