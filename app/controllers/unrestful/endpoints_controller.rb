Dir[File.join(Rails.root, 'app', 'rpc', '*.rb')].each { |file| require file }

module Unrestful
	class EndpointsController < ApplicationController

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
    rescue => exc
      fail(exc: exc, status: :internal_server_error)
		end

		private 

		def not_found(exc: nil)
			if !Rails.env.development?
        fail(exc: exc, status: :not_found)
			else
				if exc.nil?
					fail(exc: exc, status: :not_found)
				else
					raise
				end
			end
		end

    def fail(exc:, status: :bad_request)
      render json: Unrestful::FailResponse.render(exc.message) , status: status
    end

	end
end