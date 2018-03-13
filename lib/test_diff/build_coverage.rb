# TestDiff module
module TestDiff
  # class used to build the coverage file
  class BuildCoverage
    attr_reader :spec_folder, :pre_load

    def initialize(spec_folder, pre_load, continue)
      @spec_folder = spec_folder
      @pre_load = pre_load
      @batch_queue = Queue.new
      @storage = Storage.new
      @continue = continue
      RunableTests.add_all(spec_folder, @batch_queue, continue)
    end

    def run
      require 'coverage.so'
      Coverage.start

      require_boot
      require_rspec
      require_pre_load
      run_batch
    end

    private

    def require_boot
      return unless File.exist?('config/boot.rb')
      puts 'Loading config/boot.rb'
      require File.expand_path('config/boot.rb')
    end

    def require_pre_load
      return unless pre_load
      puts "pre_loading #{pre_load}"
      $LOAD_PATH << "#{Dir.getwd}/spec"
      require File.expand_path(pre_load)
    end

    def require_rspec
      puts 'Loading rspec'
      require 'rspec'
    end

    def run_batch
      puts "Running #{@batch_queue.size} tests"
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
        ENV['TEST_DIFF_COVERAGE'] = 'yes'
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
        $stderr.puts(@last_output.to_s)
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
        if file_name.include?(FileUtils.pwd)
          data[relative_file_name] = stats.join(',')
        end
      end
      @storage.set(main_spec_file, data)
      @storage.flush if @storage.respond_to?(:flush)
    end
  end

  # estimates and prints how long it will take to empty a queue
  class TimingTracker
    def self.run(queue, &block)
      new(queue).run(&block)
    end

    def initialize(queue)
      @queue = queue
      @original_size = queue_size
    end

    def run
      @start_time = Time.now
      thread = start_timing_thread
      yield
      thread.kill
    end

    private

    def queue_size
      @queue.size
    end

    def queue_completed
      @original_size - queue_size
    end

    def seconds_elapsed
      (Time.now - @start_time).to_f
    end

    def start_timing_thread
      Thread.new do
        until queue_empty?
          current_size = queue_size
          current_completed = queue_completed
          if current_completed > 0
            time_per_spec = seconds_elapsed / current_completed.to_f
            est_time_left = time_per_spec * current_size
            puts "specs left #{current_size}, est time_left: #{est_time_left.to_i}"
          end
          sleep(60)
        end
      end
    end

    def queue_empty?
      @batch_queue.empty?
    end
  end
end
