# TestDiff module
module TestDiff
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
        begin
          do_timing
        rescue => e
          puts "----- Timing failed: #{e.message} -----"
        end
      end
    end

    def do_timing
      puts "Timing #{@original_size} specs"
      until queue_empty?
        current_size = queue_size
        current_completed = queue_completed
        if current_completed > 0
          time_per_spec = seconds_elapsed / current_completed.to_f
          est_time_left = time_per_spec * current_size
          puts "specs left #{current_size}, est time_left: #{est_time_left.to_i}"
        end
        sleep(30)
      end
    end

    def queue_empty?
      @queue.empty?
    end
  end
end
