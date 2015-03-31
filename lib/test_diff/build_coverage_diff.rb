# TestDiff module
module TestDiff
  # class used to build the coverage file
  class BuildCoverageDiff
    attr_reader :spec_folder, :pre_load, :sha1

    def initialize(spec_folder, pre_load, continue)
      @spec_folder = spec_folder
      @sha1 = File.read('test_diff_coverage/sha')
      @tests_to_run = []
      @storage = Storage.new
      @pre_load = pre_load
      @continue = continue
    end

    def run
      RunableTests.new(@tests_to_run, @spec_folder).add_changed_files
      remove_tests_that_do_not_exist
      remove_tests_in_wrong_folder
      require 'coverage.so'
      Coverage.start
      require_pre_load
      run_batch
    end

    private

    def require_pre_load
      return unless pre_load
      puts "pre_loading #{pre_load}"
      require File.expand_path(pre_load)
    end

    def run_batch
      puts "Running #{@tests_to_run.size} tests"
      timing_thread = start_timing_thread(Time.now, @tests_to_run.size)
      start
      timing_thread.join
      puts 'Test done, compacting db'
      @storage.compact if @storage.respond_to?(:compact)
    end

    def start_timing_thread(start_time, original_size)
      Thread.new do
        until @tests_to_run.empty?
          last_size = @tests_to_run.size
          completed = original_size - last_size
          if completed > 0
            time_per_spec = (Time.now - start_time).to_f / completed.to_f
            est_time_left = time_per_spec * last_size
            puts "specs left #{last_size}, est time_left: #{est_time_left.to_i}"
          end
          sleep(60)
        end
      end
    end

    def start
      until @tests_to_run.empty?
        pid = start_process_fork(@tests_to_run.pop)
        pid, status =  Process.waitpid2(pid)
        fail 'Test Failed' unless status.success?
      end
      Coverage.result # disable coverage
    end

    def start_process_fork(main_spec_file)
      Process.fork do
        puts "running #{main_spec_file}"
        ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
        Time.zone_default = (Time.zone = 'UTC') if Time.respond_to?(:zone_default) && Time.zone_default.nil?
        # ARGV = ['-b',main_spec_file]
        if run_tests(main_spec_file)
          save_coverage_data(main_spec_file)
        else
          Coverage.result # disable coverage
          exit!(false) unless @continue
        end
        # ::Spec::Runner::CommandLine.run(options)
      end
    end

    def run_tests(main_spec_file)
      options ||= begin
        parser = ::Spec::Runner::OptionParser.new($stderr, $stdout)
        parser.order!(['-b', main_spec_file])
        parser.options
      end
      Spec::Runner.use options
      options.run_examples
    end

    def save_coverage_data(main_spec_file)
      data = {}
      Coverage.result.each do |file_name, stats|
        relative_file_name = file_name.gsub("#{FileUtils.pwd}/", '')
        if file_name.include?(FileUtils.pwd)
          data[relative_file_name] = stats.join(',')
        end
      end
      YAML::ENGINE.yamler = 'psych'
      @storage.set(main_spec_file, data)
      @storage.flush if @storage.respond_to?(:flush)
    end

    def remove_tests_that_do_not_exist
      @tests_to_run.delete_if do |s|
        !File.exist?(s)
      end
    end

    def remove_tests_in_wrong_folder
      @tests_to_run.delete_if do |s|
        !s.start_with?("#{spec_folder}/")
      end
    end
  end
end
