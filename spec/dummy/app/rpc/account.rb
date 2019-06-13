require 'unrestful'

module Rpc
	class Account < ::Unrestful::RpcController

    before_method :check_jwt

		def switch_owner(from:, to:)
			foo = ::AcmeFoo.new
      foo.from = from
      foo.to = to

      return foo
		end

    private

    def check_jwt
      #fail!("some shit's going down")
    end

	end
end
