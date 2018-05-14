module TestDiff
  # runs each spec and saves it to storage
  module CoverageData
    def self.get(result = ::Coverage.result)
      data = {}
      result.each do |file_name, stats|
        relative_file_name = file_name.gsub("#{FileUtils.pwd}/", '')
        is_active = stats.map(&:to_i).any?(&:nonzero?)
        if file_name.start_with?(FileUtils.pwd) && is_active
          data[relative_file_name] = stats.join(',')
        end
      end
      data
    end
  end
end
