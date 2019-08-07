module Unrestful
  class Response

    attr_accessor :ok

    def as_json
      {ok: @ok}
    end

  end
end
