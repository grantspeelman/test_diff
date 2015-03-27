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
      fail 'Data must be a Hash' unless coverage_data.is_a?(Hash)
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

    def find_for(file)
      results = []
      Dir["#{@folder}/**/*.yml"].each do |storage_file|
        find_for_storage_file(results, storage_file, file)
      end
      results
    end

    def clear
      Dir["#{@folder}/**/*.yml"].each do |storage_file|
        File.delete(storage_file)
      end
    end

    private

    def find_for_storage_file(results, storage_file, file)
      YAML::Store.new(storage_file).transaction(true) do |store|
        unless store[file].to_s.split(',').delete_if { |s| s == '' || s == '0' }.empty?
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
  end
end
