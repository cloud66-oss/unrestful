Dir[File.join(Rails.root, 'app', 'rpc', '*.rb')].each { |file| require file }
require 'net/http'
require 'uri'

module Unrestful
	class EndpointsController < ApplicationController
		include ActionController::Live
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
			
			live = true if actor.live_methods.include? method 

            actor.instance_variable_set(:@service, service)
			actor.instance_variable_set(:@method, method)
			actor.instance_variable_set(:@request, request)
			actor.instance_variable_set(:@response, response)
			actor.instance_variable_set(:@live, live)

            # only public methods
            raise "#{klass} doesn't have a method called #{method}" unless actor.respond_to? method
			
			response.headers['X-Live'] = live ? 'true' : 'false'
			return if request.head?

            actor.before_callbacks
			payload = actor.send(method, arguments)
			raise LiveError if live && !payload.nil?

			unless live 
				if payload.nil?
					render json: Unrestful::SuccessResponse.render({}.to_json)
				else
					render json: Unrestful::SuccessResponse.render(payload.as_json) 
				end
			end

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
			fail(exc: exc, status: :internal_server_error)
		rescue IOError
			# ignore as this could be the client disconnecting during streaming
		ensure 
			response.stream.close if live
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