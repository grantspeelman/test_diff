require 'yaml/store'
# TestDiff module
module TestDiff
  # class used to build the coverage file
  class Storage
    attr_reader :folder

    def initialize(folder = 'test_diff_coverage',
                   execution_times = ExecutionTimes.new('test_diff_coverage'))
      @folder = folder
      @execution_times = execution_times
      @preload_name = '_preload_'
    end

    def preload=(coverage_data)
      raise 'Data must be a Hash' unless coverage_data.is_a?(Hash)
      get_store(@preload_name).transaction do |store|
        store.roots.each do |key|
          store.delete(key)
        end
        coverage_data.keys.sort.each do |key|
          store[key] = coverage_data[key]
        end
      end
    end

    def set(file, coverage_data)
      raise 'Data must be a Hash' unless coverage_data.is_a?(Hash)
      get_store(file).transaction do |store|
        store.roots.each do |key|
          store.delete(key)
        end
        coverage_data.keys.sort.each do |key|
          store[key] = coverage_data[key]
        end
      end
    end

    def get(file)
      get_store(file).transaction(true) do |store|
        coverage_data = {}
        store.roots.each do |key|
          coverage_data[key] = store[key]
        end
        coverage_data
      end
    end

    def find_for(files, sub_folder = nil)
      results = []
      each_file(sub_folder) do |storage_file|
        find_for_storage_file(results, storage_file, files)
      end
      results
    end

    def select_tests_for(files, sub_folder = nil)
      results = []
      preload_files = preload_found_files(files)
      each_file(sub_folder) do |storage_file|
        next if storage_file.include?(@preload_name)
        if preload_files.any? || found_files(storage_file, files).any?
          results << TestInfo.new(storage_file, @execution_times[storage_file])
        end
      end
      results
    end

    def test_info_for(file)
      TestInfo.new(file, @execution_times[file])
    end

    def clear
      Dir["#{@folder}/**/*.yml"].each do |storage_file|
        File.delete(storage_file)
      end
    end

    private

    def found_files(storage_file, files)
      get_store(storage_file).transaction(true) do |store|
        files & store.roots
      end
    end

    def preload_found_files(files)
      get_store(@preload_name).transaction(true) do |store|
        files & store.roots
      end
    end

    def find_for_storage_file(results, storage_file, files)
      get_store(storage_file).transaction(true) do |store|
        found_files = files & store.roots
        found_files.each do |_file|
          results << storage_file.gsub('.yml', '').gsub("#{@folder}/", '')
        end
      end
    end

    def get_store(file)
      dir = File.dirname("#{@folder}/#{file}")
      filename = File.basename(file) + '.yml'
      FileUtils.mkdir_p(dir)
      YAML::Store.new "#{dir}/#{filename}"
    end

    def each_file(sub_folder = nil)
      root_folder = @folder
      root_folder += "/#{sub_folder}" if sub_folder
      Dir["#{root_folder}/**/*.yml"].sort.each do |full_storage_file|
        yield full_storage_file.gsub("#{@folder}/", '').gsub('.yml', '')
      end
    end
  end
end
