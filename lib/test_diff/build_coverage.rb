# TestDiff module
module TestDiff
  # class used to build the coverage file
  class BuildCoverage
    def initialize(spec_folder, pre_load, stop_on_failure, only_missing)
      @spec_folder = spec_folder
      @pre_load = pre_load
      @batch_queue = Queue.new
      @stop_on_failure = stop_on_failure
      @only_missing = only_missing
    end

    def run
      RunableTests.add_all(@spec_folder, @batch_queue, @only_missing)
      CoverageRunner.run(@batch_queue, @pre_load, !@stop_on_failure)
    end
  end
end
