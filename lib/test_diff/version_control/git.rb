require 'git'
# TestDiff module
module TestDiff
  # module for version control adapters
  module VersionControl
    # class to find changed files for git
    class Git
      def initialize(wd, last_tracked, current = 'HEAD')
        @git = ::Git.open(wd)
        @last_tracked = last_tracked
        @current = current
      end

      def changed_files
        @git.diff(@last_tracked, @current).map(&:path) +
          @git.status.select { |sf| %w[M A D].include?(sf.type) }.map(&:path)
      end
    end
  end
end
