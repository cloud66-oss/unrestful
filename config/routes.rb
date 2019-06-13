Unrestful::Engine.routes.draw do
	get 'endpoints/:model/:method', controller: :endpoints, action: :endpoint
end
