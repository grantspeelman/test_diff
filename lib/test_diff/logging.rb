# TestDiff module
module TestDiff
  # adds logging to a class
  module Logging
    def log_info(*args)
      Config.logger.info(*args)
    end

    def log_debug(*args)
      Config.logger.debug(*args)
    end

    def log_error(*args)
      Config.logger.error(*args)
    end

    module_function :log_debug, :log_info, :log_error
  end
end
