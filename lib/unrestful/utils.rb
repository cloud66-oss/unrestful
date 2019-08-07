module Unrestful
  module Utils

    def watchdog(last_words)
      yield
    rescue Exception => exc
      Rails.logger.debug "#{last_words}: #{exc}"
      #raise exc
    end

    def safe_thread(name, &block)
      Thread.new do
        Thread.current['unrestful_name'.freeze] = name
        watchdog(name, &block)
      end
    end

  end
end
