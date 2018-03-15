# TestDiff module
module TestDiff
  # class used to build the coverage file
  class BuildCoverageDiff
    def initialize(spec_folder, pre_load, continue)
      @spec_folder = spec_folder
      @sha1 = File.read('test_diff_coverage/sha')
      @pre_load = pre_load
      @continue = continue
    end

    def run
      info_files = []
      RunableTests.new(info_files, @spec_folder).add_changed_files
      batch_queue = Queue.new
      info_files.each { |info_file| batch_queue << info_file.filename }
      CoverageRunner.run(batch_queue, @pre_load, @continue)
    end
  end
end
