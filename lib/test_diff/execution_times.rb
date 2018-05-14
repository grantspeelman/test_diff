require 'test_diff/logging'

module TestDiff
  # runs each spec and saves it to storage
  class ExecutionTimes
    include Logging

    def initialize(directory = 'test_diff_coverage', filename = 'execution_times.txt')
      @file_name = "#{directory}/#{filename}"
    end

    def clear
      return unless file_exist?
      log_debug "Deleting #{@file_name}"
      File.delete(@file_name)
      reset_times
    end

    def add(main_spec_file, execution_time)
      File.open(@file_name, 'a+') do |file|
        file.write "#{main_spec_file}:#{execution_time}\n"
      end
      reset_times
    end

    def get(file)
      time = times[file]
      return nil if time.nil?
      time.to_i
    end

    alias [] :get

    private

    def times
      return {} unless file_exist?
      @times ||= Hash[File.readlines(@file_name).map(&:chomp).map { |line| line.split(':') }]
    end

    def reset_times
      @times = nil
    end

    def file_exist?
      File.exist?(@file_name)
    end
  end
end
