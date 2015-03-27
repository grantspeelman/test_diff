# TestDiff module
module TestDiff
  # Class used to calculate the tests than need to be run
  class RunDiff
    attr_reader :spec_folder, :sha1, :groups_of, :group

    def initialize(spec_folder, groups_of, group)
      @spec_folder = spec_folder
      @sha1 = File.read('test_diff_coverage/sha')
      @specs_to_run = []
      @storage = Storage.new
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
      if @specs_to_run.any?
        puts "bundle exec spec -fo #{@specs_to_run.join(' ')}"
        exec "bundle exec spec -fo #{@specs_to_run.join(' ')}"
      else
        puts 'no specs found to run'
      end
    end

    def select_test_group
      return unless groups_of
      groups_size = (@specs_to_run.length / groups_of.to_f).ceil
      @specs_to_run = @specs_to_run.slice(group.to_i * groups_size, groups_size) || []
    end

    def remove_tests_that_do_not_exist
      @specs_to_run.delete_if do |s|
        !File.exist?(s)
      end
    end

    def remove_tests_in_wrong_folder
      @specs_to_run.delete_if do |s|
        !s.start_with?("#{spec_folder}/")
      end
    end

    def add_changed_files
      _build_specs_to_run

      @specs_to_run.flatten!
      @specs_to_run.sort!
      @specs_to_run.uniq!
    end

    def _build_specs_to_run
      files = []
      `git diff --name-only #{sha1} HEAD`.split("\n").each do |file_name|
        if file_name.end_with?('spec.rb') || file_name.end_with?('test.rb')
          @specs_to_run << file_name
        elsif !file_name.start_with?(@storage.folder)
          files << file_name
          _add_rails_view_spec(file_name)
        end
      end
      _add_calculated_tests(files)
    end

    def _add_calculated_tests(files)
      @specs_to_run << @storage.find_for(files, spec_folder)
    end

    def _add_rails_view_spec(file_name)
      # try and find a matching view spec
      return unless file_name.include?('app/views')
      view_spec_name = file_name.gsub('app/views', "#{spec_folder}/views").gsub('.erb', '.erb_spec.rb')
      return unless  File.exist?(view_spec_name)
      @specs_to_run << view_spec_name
    end
  end
end
