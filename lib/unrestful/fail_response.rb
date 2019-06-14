require_relative 'response'

module Unrestful
	class FailResponse < Unrestful::Response
		
		attr_accessor :message
		attr_accessor :exception 
		
		def self.render(message, exc: nil)
			obj = Unrestful::FailResponse.new
			obj.message = message
			obj.exception = exc unless exc.nil?
			obj.ok = false
			
			return obj.as_json
		end
		
		def as_json
			result = { message: message }
			result.merge!({ exception: exception }) if Rails.env.development?
			super.merge(result)
		end
		
	end
end