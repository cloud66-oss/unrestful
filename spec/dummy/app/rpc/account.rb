require 'unrestful'

module Rpc
	class Account < ::Unrestful::RpcController
		include Unrestful::JwtSecured
		scopes({
			switch_owner: ['write:account'],
			migrate: ['read:account'],
			long_one: ['read:account']
		})
		live(['migrate'])
		async(['long_one'])

		before_method :authenticate_request!
		#after_method :do_something
		
		def switch_owner(from:, to:)
			foo = ::AcmeFoo.new
			foo.from = from
			foo.to = to

			return foo
		end

		def migrate(repeat:)
			repeat.to_i.times {
				write "hello\n"
				sleep 1
			}

			return nil 
		end

		def long_one
			return { not_done_yet: true }
		end
		
	end
end
