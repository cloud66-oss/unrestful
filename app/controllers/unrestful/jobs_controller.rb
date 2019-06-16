module Unrestful
	class JobsController < ApplicationController
		include ActionController::Live
		# TODO: JWT check

		def status
			job = AsyncJob.new(job_id: params[:job_id])
			render(json: Unrestful::FailResponse.render("job #{job.job_id} doesn't exist"), status: :not_found) and return unless job.valid?

			render json: job.as_json
		end

		def live
			job = AsyncJob.new(job_id: params[:job_id])
			response.headers['Content-Type'] = 'text/event-stream'

			trap(:INT) { raise StreamInterrupted }

			ticker = Thread.new { job.redis.publish("heartbeat","thump"); sleep 5 }
			sender = Thread.new do
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
			job.unsubscribe unless job.nil?
		rescue StreamInterrupted
			job.unsubscribe unless job.nil?
		ensure
			ticker.kill if ticker
			sender.kill if sender
			response.stream.close
		end
	end
end

