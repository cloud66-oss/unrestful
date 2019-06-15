# frozen_string_literal: true
require 'jwt'

module Unrestful
	module JwtSecured
		extend ActiveSupport::Concern
	
		private
	
		def authenticate_request!
			@auth_payload, @auth_header = auth_token
		
			raise AuthError, 'Insufficient scope' unless scope_included
		end

		def http_token
			if request.headers['Authorization'].present?
				request.headers['Authorization'].split(' ').last
			end
		end
	
		def auth_token
			JsonWebToken.verify(http_token)
		end

		def scope_included
			if self.class.assigned_scopes[@method] == nil
			  false
			else
			  (String(@auth_payload['scope']).split(' ') & (self.class.assigned_scopes[@method])).any?
			end
		end
	end
end