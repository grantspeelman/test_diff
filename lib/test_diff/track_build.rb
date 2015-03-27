require 'git'

# TestDiff module
module TestDiff
  # Class used to calculate the tests than need to be run
  class TrackBuild
    def initialize(sha)
      @sha = sha
    end

    def run
      git = Git.open('.')
      sha = git.object(@sha || 'HEAD').sha
      File.open('test_diff_coverage/sha', 'w+') { |f| f << sha }
    end
  end
end
