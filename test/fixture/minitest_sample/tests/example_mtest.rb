require 'minitest'

# example test class
class TestExample < Minitest::Test
  def setup
    @example = Example.new
  end

  def test_that_run
    @example.run
    assert @example.did_i_run?
  end

  def test_that_did_not_run
    refute @example.did_i_run?
  end

  def test_that_will_be_skipped
    skip 'test this later'
  end
end
