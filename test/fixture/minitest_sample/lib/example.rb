# example class
class Example
  def initialize
    @run = 0
  end

  def run
    @run += 1
  end

  def did_i_run?
    @run > 0
  end
end
