require_relative 'response'

module Unrestful
  class SuccessResponse < Unrestful::Response

    attr_accessor :payload

    def self.render(payload)
      obj = Unrestful::SuccessResponse.new
      obj.payload = payload
      obj.ok = true

      return obj.as_json
    end

    def as_json
      super.merge({payload: payload})
    end
  end
end
