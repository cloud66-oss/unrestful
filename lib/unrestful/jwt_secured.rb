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
				# strip off the Bearer
				request.headers['Authorization'].split(' ').last
			end
		end

		def auth_token
			JsonWebToken.verify(http_token)
		end

		def scope_included
			permissions_required = class_assigned_scopes
			permissions_present = @auth_payload['permissions'] || []
			# ensure that we have the required permission to call the method
			(permissions_present & permissions_required).any?
		end

		def class_assigned_scopes
			class_assigned_scopes = self.class.assigned_scopes[@method] || []
			# ensure that we have a scope defined for this method, and that it has an array value
			if class_assigned_scopes.nil? || class_assigned_scopes.empty? || !class_assigned_scopes.is_a?(Array)
				raise "#{self.class.name} MUST declare a \"scopes\" hash that INCLUDES key \"#{@method}\" with value of an array of permissions"
			end
			class_assigned_scopes
		rescue NoMethodError
			raise "#{self.class.name} MUST implement ::Unrestful::RpcController AND declare \"scopes\" for each method request, with its corresponding array of permissions"
		end
	end
end
