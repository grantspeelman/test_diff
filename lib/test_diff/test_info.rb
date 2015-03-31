# TestDiff module
module TestDiff
  # class used to hold infomation about the test
  class TestInfo
    include Comparable
    attr_reader :execution_time, :filename
    FIXNUM_MAX = (2**(0.size * 8 - 2) - 1)

    def initialize(f, et)
      @filename = f
      @execution_time = et
    end

    def compare_execution_time
      @execution_time || FIXNUM_MAX
    end

    def <=>(other)
      if compare_execution_time == other.compare_execution_time
        filename <=> other.filename
      else
        compare_execution_time <=> other.compare_execution_time
      end
    end
  end
end
