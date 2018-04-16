# TestDiff module
module TestDiff
  # estimates and prints how long it will take to empty a queue
  class TimingTracker
    def self.run(queue, &block)
      new(queue).run(&block)
    end

    include Logging

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

    def seconds_elapsed
      (Time.now - @start_time).to_f
    end

    def start_timing_thread
      Thread.new do
        begin
          do_timing
        rescue => e
          log_error "----- Timing failed: #{e.message} -----"
        end
      end
    end

    def do_timing
      log_info "Timing #{@original_size} specs"
      sleep_time = 90.0
      until queue_empty?
        last_current_size = queue_size
        sleep(sleep_time)
        current_size = queue_size
        current_completed = last_current_size - current_size
        if current_completed > 0
          est_time_left = (sleep_time / current_completed.to_f) * current_size
          log_info "specs left #{current_size}, est time_left: #{est_time_left.to_i}"
        else
          log_info "specs left #{current_size}, est time_left: N/A"
        end
      end
    end

    def queue_empty?
      @queue.empty?
    end
  end
end
