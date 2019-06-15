Unrestful::Engine.routes.draw do
	post ':service/:method', controller: :endpoints, action: :endpoint
end
