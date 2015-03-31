require 'singleton'
# TestDiff module
module TestDiff
  # Holds all the configuration details
  class Config
    include Singleton
    attr_accessor :working_directory, :map_subfolder,
                  :current_tracking_filename, :test_pattern

    attr_writer :test_runner, :version_control, :storage

    def initialize
      self.working_directory = '.'
      self.map_subfolder = 'test_diff_coverage'
      self.current_tracking_filename = 'sha'
      self.test_pattern = /spec.rb\z/
    end

    def version_control
      @version_control ||= VersionControl::Git.new(working_directory,
                                                   File.read(current_tracking_file))
    end

    def storage
      @storage ||= Storage.new(map_folder)
    end

    def test_runner
      @test_runner ||= TestRunner::Rspec.new
    end

    def map_folder
      "#{working_directory}/#{map_subfolder}"
    end

    def current_tracking_file
      "#{map_folder}/#{current_tracking_filename}"
    end

    def self.method_missing(method, *args)
      if instance.respond_to?(method)
        instance.send(method, *args)
      else
        super
      end
    end
  end
end
