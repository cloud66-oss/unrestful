module Unrestful
  class RpcController

    attr_reader :service
    attr_reader :method
    attr_reader :request
    attr_reader :response
    attr_reader :live
    attr_reader :async
    attr_reader :job

    class_attribute :before_method_callbacks, default: ActiveSupport::HashWithIndifferentAccess.new
    class_attribute :after_method_callbacks, default: ActiveSupport::HashWithIndifferentAccess.new
    class_attribute :assigned_scopes, default: ActiveSupport::HashWithIndifferentAccess.new
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
      msg = message.end_with?("\n") ? message : "#{message}\n"
      response.stream.write msg
    end

    protected

    def self.before_method(method, options = {})
      self.before_method_callbacks = {method => options}
    end

    def self.after_method(method, options = {})
      self.after_method_callbacks = {method => options}
    end

    def self.scopes(scope_list)
      self.assigned_scopes = ActiveSupport::HashWithIndifferentAccess.new(scope_list)
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
