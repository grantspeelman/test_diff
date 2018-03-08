require File.expand_path '../../../test_helper.rb', __FILE__

describe TestDiff::VersionControl::Git do
  subject { TestDiff::VersionControl::Git }

  describe '#changed_files' do
    it 'returns only the changed files' do
      g = subject.new((File.expand_path '../../../../', __FILE__), 'bd3b3ee', 'd5a979d')
      files = g.changed_files
      files.must_equal(
        %w[exe/test_diff lib/test_diff.rb lib/test_diff/build_coverage_diff.rb
           lib/test_diff/run_diff.rb lib/test_diff/version.rb]
      )
    end
  end
end
