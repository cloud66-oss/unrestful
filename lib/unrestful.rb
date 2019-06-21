require "unrestful/engine"

Dir[File.join(__dir__, 'unrestful', '*.rb')].each { |file| require file }

module Unrestful
	def self.configure(options = {}, &block)
		@config = Unrestful::Config.new(options)

		@config
	end

	def self.configuration
		@config || Unrestful::Config.new({})
	end

  class Config
	def initialize(options)
		@options = options
	end

	def redis_address
		@options[:redis_address] || ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
	end
  end
end
