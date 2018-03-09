require 'git'
# TestDiff module
module TestDiff
  # module for version control adapters
  module VersionControl
    # class to find changed files for git
    class Git
      include Logging

      # log all git logger info on debug level
      class AllDebugLogger < SimpleDelegator
        def warning(*args)
          debug(*args)
        end

        def info(*args)
          debug(*args)
        end
      end

      def initialize(wd, last_tracked, current = 'HEAD')
        # @git = ::Git.open(wd, log: AllDebugLogger.new(Config.logger))
        @git = ::Git.open(wd)
        @last_tracked = last_tracked
        @current = current
      end

      def changed_files
        (unstaged_changed_files + unstaged_added_files).uniq
      end

      private

      def diff_changed_files
        @git.diff(@last_tracked, @current).map(&:path).tap do |files|
          log_debug "diff_changed_files: #{files.join(',')}"
        end
      end

      def unstaged_changed_files
        @git.status.changed.tap do |file_hash|
          log_debug "unstaged_changed_files: #{file_hash.keys.join(',')}"
        end.keys
      end

      def unstaged_added_files
        @git.status.added.tap do |file_hash|
          log_debug "unstaged_added_files: #{file_hash.keys.join(',')}"
        end.keys
      end
    end
  end
end
