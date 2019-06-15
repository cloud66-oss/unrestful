Dir[File.join(Rails.root, 'app', 'rpc', '*.rb')].each { |file| require file }
require 'net/http'
require 'uri'

module Unrestful
	class EndpointsController < ApplicationController
		protect_from_forgery unless: -> { request.format.json? }

		INVALID_PARAMS = [:method, :service, :controller, :action, :endpoint]
		
        def endpoint 
            method = params[:method]
            service = params[:service]
            service_class = service.camelize.singularize
			
			arguments = params.to_unsafe_h.symbolize_keys.reject { |x| INVALID_PARAMS.include? x }

			klass = "::Rpc::#{service_class}".constantize
            
            raise NameError, "#{klass} is not a Unrestful::RpcController" unless klass <= ::Unrestful::RpcController
            actor = klass.new
            actor.instance_variable_set(:@service, service)
			actor.instance_variable_set(:@method, method)
			actor.instance_variable_set(:@request, request)
            
            # only public methods
            raise "#{klass} doesn't have a method called #{method}" unless actor.respond_to? method
            
            actor.before_callbacks
            payload = actor.send(method, arguments)
            render json: Unrestful::SuccessResponse.render(payload.as_json)
            actor.after_callbacks
        rescue NameError => exc
            not_found(exc: exc)
        rescue ArgumentError => exc
            fail(exc: exc)
        rescue ::Unrestful::FailError => exc
			fail(exc: exc)
		rescue ::Unrestful::Error => exc
			fail(exc: exc)
		rescue => exc
			raise exc if Rails.env.development?
            fail(exc: exc, status: :internal_server_error)
        end
        
        private 
        
        def not_found(exc:)
            if !Rails.env.development?
                fail(exc: exc, status: :not_found)
            else
                raise exc
            end
        end
        
		def fail(exc:, status: :bad_request, message: nil)
			raise ArgumentError if exc.nil? && message.nil? 
			msg = exc.nil? ? message : exc.message
            render json: Unrestful::FailResponse.render(msg, exc: exc) , status: status
		end
	end
end