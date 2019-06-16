Unrestful::Engine.routes.draw do
	get 'jobs/status/:job_id', controller: :jobs, action: :status, as: :job_status
	get 'jobs/live/:job_id', controller: :jobs, action: :live, as: :job_live
	match 'rpc/:service/:method', controller: :endpoints, action: :endpoint, as: :endpoint, via: [:get, :post]
end
