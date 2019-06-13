Dir[File.join(Rails.root, 'app', 'rpc', '*.rb')].each { |file| require file }

module Unrestful
	class EndpointsController < ApplicationController
		
		ISSUER = 'https://cloud66.com'
		LEEWAY = 30
		AUDIENCE = ['ACME']
		
        def endpoint 
            method = params[:method]
            model = params[:model]
            model_class = model.camelize.singularize
            
            arguments = request.query_parameters.symbolize_keys.reject { |x| [:method, :model].include? x }
            
            klass = "::Rpc::#{model_class}".constantize
            
            raise NameError, "#{klass} is not a Unrestful::RpcController" unless klass <= ::Unrestful::RpcController
            actor = klass.new
            actor.instance_variable_set(:@model, model)
			actor.instance_variable_set(:@method, method)
			actor.instance_variable_set(:@token, token)
            
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
		rescue JWT::IncorrectAlgorithm => exc 
			fail(exc: exc, status: :bad_request, message: 'Bad JWT')
		rescue JWT::InvalidIssuerError => exc
			fail(exc: exc, status: :unauthorized, message: 'Invalid issuer')
		rescue JWT::ExpiredSignature => exc
			fail(exc: exc, status: :unauthorized, message: 'Token expire')
		rescue JWT::InvalidAudError => exc 
			fail(exc: exc, status: :unauthorized, message: 'Invalid audience')
        rescue => exc
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
            render json: Unrestful::FailResponse.render(message.nil? ? exc.message : message, exc: exc) , status: status
		end
		
		def token
			header = request.headers['Authorization']
			header = header.split(' ').last if header

			return JWT.decode(header, jwt.rsa_public, true, { 
				iss: ISSUER, 
				verify_iss: true, 
				algorithm: 'RS256',
				exp_leeway: LEEWAY,
				aud: AUDIENCE, 
				verify_aud: true,
			})
		end

		def jwt 
			@jwt || Unrestful::Jwt.new
		end
        
    end
end