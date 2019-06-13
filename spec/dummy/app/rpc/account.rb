require 'unrestful'

module Rpc
	class Account < ::Unrestful::RpcController
		
		#before_method :check_jwt
		#after_method :do_something
		
		def switch_owner(from:, to:)
			foo = ::AcmeFoo.new
			foo.from = from
			foo.to = to
			puts @token

			return foo
		end
		
		private
		
		def check_jwt
			#fail!("something's wrong")
		end
		
	end
end
