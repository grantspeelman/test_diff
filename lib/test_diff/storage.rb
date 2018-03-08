require 'yaml/store'
# TestDiff module
module TestDiff
  # class used to build the coverage file
  class Storage
    attr_reader :folder

    def initialize(folder = 'test_diff_coverage')
      @folder = folder
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
      root_folder = @folder
      root_folder += "/#{sub_folder}" if sub_folder
      Dir["#{root_folder}/**/*.yml"].each do |storage_file|
        find_for_storage_file(results, storage_file, files)
      end
      results
    end

    def select_tests_for(files, sub_folder = nil)
      results = []
      root_folder = @folder
      root_folder += "/#{sub_folder}" if sub_folder
      Dir["#{root_folder}/**/*.yml"].each do |storage_file|
        select_tests_for_storage_file(results, storage_file, files)
      end
      results
    end

    def test_info_for(file)
      result = TestInfo.new(file, nil)
      YAML::Store.new("#{file}.yml").transaction(true) do |store|
        result = TestInfo.new(file, store['__execution_time__'])
      end
      result
    rescue PStore::Error => e
      STDERR.puts e.message
      result
    end

    def clear
      Dir["#{@folder}/**/*.yml"].each do |storage_file|
        File.delete(storage_file)
      end
    end

    private

    def find_for_storage_file(results, storage_file, files)
      YAML::Store.new(storage_file).transaction(true) do |store|
        found_files = files & store.roots
        found_files.each do |file|
          if _active_file?(store[file])
            results << storage_file.gsub('.yml', '').gsub("#{@folder}/", '')
          end
        end
      end
    end

    def select_tests_for_storage_file(results, storage_file, files)
      YAML::Store.new(storage_file).transaction(true) do |store|
        found_files = files & store.roots
        found_files.each do |file|
          next unless _active_file?(store[file])
          results << TestInfo.new(
            storage_file.gsub('.yml', '').gsub("#{@folder}/", ''),
            store['__execution_time__']
          )
        end
      end
    end

    def _active_file?(file)
      !file.to_s.split(',').delete_if { |s| s == '' || s == '0' }.empty?
    end

    def get_store(file)
      dir = File.dirname("#{@folder}/#{file}")
      filename = File.basename(file) + '.yml'
      FileUtils.mkdir_p(dir)
      YAML::Store.new "#{dir}/#{filename}"
    end
  end
end
