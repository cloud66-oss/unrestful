module Unrestful
	class JobsController < ApplicationController
		include ActionController::Live
		include Unrestful::Utils
		include Unrestful::JwtSecured

		before_action :authenticate_request!

		def status
			job = AsyncJob.new(job_id: params[:job_id])
			render(json: Unrestful::FailResponse.render("job #{job.job_id} doesn't exist"), status: :not_found) and return unless job.valid?

			render json: job.as_json
		end

		def live
			job = AsyncJob.new(job_id: params[:job_id])
			response.headers['Content-Type'] = 'text/event-stream'

			# this might be messy but will breakout of redis subscriptions when 
			# the app needs to be shutdown
			trap(:INT) { raise StreamInterrupted } 

			# this is to keep redis connection alive during long sessions
			ticker = safe_thread "ticker:#{job.job_id}" do
				loop { job.redis.publish("unrestful:heartbeat", 1); sleep 5 }
			end
			sender = safe_thread "sender:#{job.job_id}" do
				job.subscribe do |on|
					on.message do |chn, message|
						# we need to add a newline at the end or
						# it will get stuck in the buffer
						msg = message.end_with?("\n") ? message : "#{message}\n"
						response.stream.write msg
					end
				end
			end
			ticker.join
			sender.join
		rescue Redis::TimeoutError
			# ignore this
		rescue AsyncError => exc
			render json: Unrestful::FailResponse.render(exc.message, exc: exc) , status: :not_found
		rescue IOError
			# ignore as this could be the client disconnecting during streaming
			job.unsubscribe if job
		rescue StreamInterrupted
			job.unsubscribe if job
		ensure
			ticker.kill if ticker
			sender.kill if sender
			response.stream.close
			job.close if job
		end

		private 

		# overwriting this as scopes don't apply to this controller
		def scope_included
			true 
		end
	end
end

