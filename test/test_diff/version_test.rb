require File.expand_path '../../test_helper.rb', __FILE__

describe TestDiff do
  it 'it has a version number' do
    _(::TestDiff::VERSION).wont_be_nil
  end
end
