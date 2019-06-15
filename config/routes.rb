Unrestful::Engine.routes.draw do
	match ':service/:method', controller: :endpoints, action: :endpoint, as: :endpoint, via: [:get, :post]
end
