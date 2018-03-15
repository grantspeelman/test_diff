# TestDiff module
module TestDiff
  # class used to build the coverage file
  class BuildCoverage
    def initialize(spec_folder, pre_load, continue)
      @spec_folder = spec_folder
      @pre_load = pre_load
      @batch_queue = Queue.new
      @continue = continue
    end

    def run
      RunableTests.add_all(@spec_folder, @batch_queue, @continue)
      CoverageRunner.run(@batch_queue, @pre_load, @continue)
    end
  end
end
