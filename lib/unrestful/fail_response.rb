require_relative 'response'
require 'json/add/exception'

module Unrestful
	class FailResponse < Unrestful::Response
		
		attr_accessor :message
		attr_accessor :exception 
		
		def self.render(message, exc: nil)
			obj = Unrestful::FailResponse.new
			obj.message = message
			obj.exception = exc if !exc.nil? && Rails.env.development?
			obj.ok = false
			
			return obj.as_json
		end
		
		def as_json
			result = { message: message }
			result.merge!({ exception: exception }) unless exception.nil?
			super.merge(result)
		end
		
	end
end