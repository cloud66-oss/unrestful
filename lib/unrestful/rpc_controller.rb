module Unrestful
  class RpcController

    attr_reader :service
	attr_reader :method
	attr_reader :request
	attr_reader :response
	attr_reader :live
	attr_reader :async
	attr_reader :async_job_id

    class_attribute :before_method_callbacks, default: {}
	class_attribute :after_method_callbacks, default: {}
	class_attribute :assigned_scopes, default: {}
	class_attribute :live_methods, default: []
	class_attribute :async_methods, default: []

    def before_callbacks
      self.class.before_method_callbacks.each do |k, v|
        # no checks for now
        self.send(k)
      end
    end

    def after_callbacks
      self.class.after_method_callbacks.each do |k, v|
        self.send(k)
      end
	end

	def write(message)
		raise NotLiveError unless live
		response.stream.write "#{message}\n"
	end
	
    protected

    def self.before_method(method, options = {})
      self.before_method_callbacks = { method => options }
    end

    def self.after_method(method, options = {})
      self.after_method_callbacks = { method => options }
	end

	def self.scopes(scope_list)
		self.assigned_scopes = scope_list
	end

	def self.live(live_list)
		self.live_methods = live_list
	end

	def self.async(async_list)
		self.async_methods = async_list
	end
	
    def fail!(message = "")
      raise ::Unrestful::FailError, message
    end

  end
end
