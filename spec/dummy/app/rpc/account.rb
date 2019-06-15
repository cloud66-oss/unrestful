require 'unrestful'

module Rpc
	class Account < ::Unrestful::RpcController
		include Unrestful::JwtSecured
		scopes({'switch_owner' => ['write:account']})

		before_method :authenticate_request!
		#after_method :do_something
		
		def switch_owner(from:, to:)
			foo = ::AcmeFoo.new
			foo.from = from
			foo.to = to

			return foo
		end
		
	end
end
