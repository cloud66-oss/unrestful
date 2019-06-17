require 'redis'

module Unrestful
	class AsyncJob
		include ActiveModel::Serializers::JSON

		ALLOCATED = 0
		RUNNING = 1
		FAILED = 2
		SUCCESS = 3

		KEY_TIMEOUT = 3600
		KEY_LENGTH = 10
		CHANNEL_TIMEOUT = 10

		attr_reader :job_id

		def attributes
			{
				job_id: job_id,
				state: state,
				last_message: last_message,
				ttl: ttl
			}
		end

		def initialize(job_id: nil)
			if job_id.nil?
				@job_id = SecureRandom.hex(KEY_LENGTH)
			else
				@job_id = job_id
			end
		end

		def update(state, message: '')
			raise ArgumentError, 'failed states must have a message' if message.blank? && state == FAILED

			redis.set(job_key, state)
			redis.set(job_message, message) unless message.blank?

			if state == ALLOCATED
				redis.expire(job_key, KEY_TIMEOUT)
				redis.expire(job_message, KEY_TIMEOUT)
			end
		end

		def ttl
			redis.ttl(job_key)
		end

		def state
			redis.get(job_key)
		end

		def last_message
			redis.get(job_message)
		end

		def delete
			redis.del(job_key)
			redis.del(job_message)
		end

		def subscribe(timeout: CHANNEL_TIMEOUT, &block)
			raise AsyncError, "job #{job_key} doesn't exist" unless valid?

			redis.subscribe_with_timeout(timeout, job_channel, &block)
		end

		def publish(message)
			raise AsyncError, "job #{job_key} doesn't exist" unless valid?

			redis.publish(job_channel, message)
		end

		def valid?
			redis.exists(job_key)
		end

		def unsubscribe
			redis.unsubscribe(job_channel)
		rescue 
			# ignore unsub errors
		end

		def redis
			# TODO: Config
			@redis ||= Redis.new
		end

		def close
			redis.unsubscribe(job_channel) if redis.subscribed?
		ensure 
			@redis.quit
		end

		private

		def job_key
			"unrestful:job:state:#{@job_id}"
		end

		def job_channel
			"unrestful:job:channel:#{@job_id}"
		end

		def job_message
			"unrestful:job:message:#{@job_id}"
		end

	end
end
