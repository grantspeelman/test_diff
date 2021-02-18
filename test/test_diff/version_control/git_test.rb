require File.expand_path '../../../test_helper.rb', __FILE__

require 'singleton'
require 'ostruct'

class DummyGit
  include Singleton

  def self.open(working_directory)
    instance.working_directory = working_directory
    instance
  end

  attr_accessor :working_directory
  attr_reader :diff_from, :diff_to

  def diff(diff_from, diff_to)
    @diff_from = diff_from
    @diff_to = diff_to
    [OpenStruct.new(path: 'files_here')]
  end
end

describe TestDiff::VersionControl::Git do
  subject { TestDiff::VersionControl::Git }

  describe '#changed_files' do
    it 'returns only the changed files' do
      g = subject.new('working_dir', 'bd3b3ee', 'd5a979d', DummyGit)
      files = g.changed_files
      _(files).must_equal(%w[files_here])
      dummy_git = DummyGit.instance
      _(dummy_git.working_directory).must_equal('working_dir')
      _(dummy_git.diff_from).must_equal('bd3b3ee')
      _(dummy_git.diff_to).must_equal('d5a979d')
    end
  end
end
