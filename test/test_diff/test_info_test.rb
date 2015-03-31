require File.expand_path '../../test_helper.rb', __FILE__

describe TestDiff::TestInfo do
  describe 'Comparable' do
    it 'same values are equal' do
      t1 = TestDiff::TestInfo.new('a', 1)
      t2 = TestDiff::TestInfo.new('a', 1)
      t1.must_equal(t2)
    end

    it 'lower execution time is smaller' do
      t1 = TestDiff::TestInfo.new('a', 1)
      t2 = TestDiff::TestInfo.new('a', 2)
      t1.must_be :<, t2
    end

    it 'same execution then text is compare' do
      t1 = TestDiff::TestInfo.new('b', 2)
      t2 = TestDiff::TestInfo.new('a', 2)
      t1.must_be :>, t2
    end

    it 'nil execution time is bigger' do
      t1 = TestDiff::TestInfo.new('a', 1)
      t2 = TestDiff::TestInfo.new('a', nil)
      t1.must_be :<, t2
    end

    it 'nil execution time is bigger (other size)' do
      t1 = TestDiff::TestInfo.new('a', nil)
      t2 = TestDiff::TestInfo.new('a', 1)
      t1.must_be :>, t2
    end
  end
end
