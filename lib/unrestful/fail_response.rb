require_relative 'response'

module Unrestful
  class FailResponse < Unrestful::Response

    attr_accessor :message

    def self.render(message)
      obj = Unrestful::FailResponse.new
      obj.message = message
      obj.ok = false

      return obj.as_json
    end

    def as_json
      super.merge({ message: message })
    end

  end
end