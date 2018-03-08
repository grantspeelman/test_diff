require 'git'
# TestDiff module
module TestDiff
  # module for version control adapters
  module VersionControl
    # class to find changed files for git
    class Git
      include Logging

      def initialize(wd, last_tracked, current = 'HEAD')
        @git = ::Git.open(wd)
        @last_tracked = last_tracked
        @current = current
      end

      def changed_files
        (diff_changed_files + unstaged_changed_files).uniq
      end

      private

      def diff_changed_files
        @git.diff(@last_tracked, @current).map(&:path).tap do |files|
          log_debug "diff_changed_files: #{files.join(',')}"
        end
      end

      def unstaged_changed_files
        @git.status.select { |sf| %w[M A D].include?(sf.type) }.map(&:path).tap do |files|
          log_debug "unstaged_changed_files: #{files.join(',')}"
        end
      end
    end
  end
end
