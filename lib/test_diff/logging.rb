# TestDiff module
module TestDiff
  # adds logging to a class
  module Logging
    def log_info(*args)
      Config.logger.info(*args)
    end

    def log_debug(*args)
      Config.logger.info(*args)
    end

    module_function :log_debug, :log_info
  end
end
