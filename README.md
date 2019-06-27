<img src="http://cdn2-cloud66-com.s3.amazonaws.com/images/oss-sponsorship.png" width=150/>

# Unrestful

REST is not fit for all use cases. Most of RPC frameworks are too heavy and complicated and require a lot of Ops involvement.

Unrestful is a lightweight simple RPC framework for Rails that can sit next to your existing application. It supports the following:

- Simple procedure calls over HTTP
- Streaming
- Async jobs and async job log streaming and status tracking

## Dependencies

Unrestful requires Rails 5.2 (can work with earlier versions) and Redis.
In development environments, Unrestful requires a multi-threaded web server like Puma. (it won't work with Webrick).

## Usage

Mount Unrestful on your Rails app:

```ruby
Rails.application.routes.draw do
  # ...
  mount Unrestful::Engine => "/mount/path"
  # ...
end
```

This will add the following paths to your application:

```
/mount/path/rpc/:service/:method
/mount/path/jobs/status/:job_id
/mount/path/jobs/live/:job_id
```

You can start your Rails app as normal.

## Services and Method

Unrestful looks for files under `app/models/rpc` to find the RPC method. Any class should be derived from `::Unrestful::RpcController` to be considered. Here is an example:

```ruby
require 'unrestful'

module Rpc
	class Account < ::Unrestful::RpcController
		include Unrestful::JwtSecured
		scopes({
			'switch_owner' => ['write:account'],
			'migrate' => ['read:account'],
			'long_one' => ['read:account']
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
```

NOTE: All parameters on all RPC methods should be named.

`POST` or `GET` parameters will be used to call the RPC method using their names. For example, `{ "from": "you", "to": "me" }` as a HTTP POST payload on `rpc/account/switch_owner` will be used to call the method with the corresponding parameters.

NOTE: Both `rpc/accounts` and `rpc/account` are accepted.

The three methods in the example above, support the 3 types of RPC calls Unrestful supports:

### Synchronous calls

Sync calls are called and return a value within the same HTTP session. `switch_owner` is an example of that. Any returned value will be wrapped in `Unrestful::Response` and sent to the client (this could be a `SuccessResponse` or `FailResponse` if there is an exception).

### Live calls

Live calls are calls that hold the client and send live logs of progress down the wire. They might be cancelled mid-flow if the client disconnects. Live methods should be named in the `live` class method and can use the `write` method to send live information back to the client.

### Asynchronous calls

Async calls are like sync calls, but return a job id which can be used to track the background job's progress and perhaps follow its logs. Use the `jobs/status` and `jobs/live` end points for those purposes. Async calls should be named in the `async` class method and can use `@job` (`Unrestful::AsyncJob`) to update job status or publish logs for the clients.

## Code

Most of the code for Unrestful is in 2 controllers: `Unrestful::EndpointsController` and `Unrestful::JobsController`. Most fo your questions will be answered by looking at those 2 methods!

## Authorization

By default Unrestful doesn't impose any authentication or authorization on the callers. However it comes with a prewritten JWT authorizer which can be used by using `include Unrestful::JwtSecured` in your own RPCController. This will look for a JWT on the header, will validate it and return the appropriate response.

The simplest way to use Unrestful with JWT is to use a tool like Auth0. Create you API and App and use it to generate and use the tokens when making calls to Unrestful.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'unrestful'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install unrestful
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0).
