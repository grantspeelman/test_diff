module TestDiff
  # runs each spec and saves it to storage
  class CoverageRunner
    def self.run(batch_queue, pre_load, continue)
      new(batch_queue, pre_load, continue).run
    end

    def initialize(batch_queue, pre_load, continue)
      @pre_load = pre_load
      @batch_queue = batch_queue
      @storage = Storage.new
      @continue = continue
    end

    def run
      require 'coverage.so'
      Coverage.start

      ENV['TEST_DIFF_COVERAGE'] = 'yes'

      require_boot
      require_rspec
      require_pre_load
      pre_run_checks
      run_batch
    end

    private

    def require_boot
      if File.exist?('config/boot.rb')
        puts 'Loading config/boot.rb'
        require File.expand_path('config/boot.rb')
      elsif File.exist?('Gemfile')
        puts 'Bundler setup'
        ENV['BUNDLE_GEMFILE'] ||= File.expand_path('Gemfile')
        require 'bundler/setup'
      end
    end

    def require_pre_load
      return unless @pre_load
      puts "pre_loading #{@pre_load}"
      $LOAD_PATH << "#{Dir.getwd}/spec"
      require File.expand_path(@pre_load)
    end

    def require_rspec
      puts 'Loading rspec/core'
      require 'rspec/core'
    end

    def pre_run_checks
      raise 'please disable simplecov while using test_diff. Check README.md for examples' if defined?(SimpleCov)
    end

    def run_batch
      TimingTracker.run(@batch_queue) { start }
      puts 'Test done, compacting db'
      @storage.compact if @storage.respond_to?(:compact)
    end

    def start
      until @batch_queue.empty?
        pid = start_process_fork(@batch_queue.pop(true))
        _pid, status = Process.waitpid2(pid)
        raise 'Test Failed' unless status.success?
      end
      Coverage.result # disable coverage
    end

    def start_process_fork(main_spec_file)
      Process.fork do
        puts "running #{main_spec_file}"
        ActiveRecord::Base.connection.reconnect! if defined?(ActiveRecord::Base)
        Time.zone_default = (Time.zone = 'UTC') if Time.respond_to?(:zone_default) && Time.zone_default.nil?
        run_test(main_spec_file)
      end
    end

    def run_test(main_spec_file)
      s = Time.now
      result = run_tests(main_spec_file)
      if result
        save_coverage_data(main_spec_file, Time.now - s)
      else
        $stderr.puts(@last_output.string)
        Coverage.result # disable coverage
        exit!(false) unless @continue
      end
    end

    def run_tests(main_spec_file)
      @last_output = StringIO.new
      ::RSpec::Core::Runner.run([main_spec_file], @last_output, @last_output).zero?
    end

    def save_coverage_data(main_spec_file, execution_time)
      data = { '__execution_time__' => execution_time }
      Coverage.result.each do |file_name, stats|
        relative_file_name = file_name.gsub("#{FileUtils.pwd}/", '')
        if file_name.start_with?(FileUtils.pwd)
          data[relative_file_name] = stats.join(',')
        end
      end
      @storage.set(main_spec_file, data)
      @storage.flush if @storage.respond_to?(:flush)
    end
  end
end
