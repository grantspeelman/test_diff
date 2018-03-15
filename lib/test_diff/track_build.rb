require 'git'

# TestDiff module
module TestDiff
  # Class used to calculate the tests than need to be run
  class TrackBuild
    def initialize(sha, git_dir)
      @git_dir = git_dir
      @sha = sha
    end

    def run
      git = Git.open(@git_dir || '.')
      sha = git.object(@sha || 'HEAD').sha
      File.open('test_diff_coverage/sha', 'w+') { |f| f << sha }
      puts 'updated test_diff_coverage/sha'
    end
  end
end
