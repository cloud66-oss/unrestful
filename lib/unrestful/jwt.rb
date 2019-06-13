require 'jwt'

module Unrestful
	class Jwt 

		attr_reader :rsa_public
		attr_reader :rsa_private

		def initialize
			# TODO: use options to pick the key from the right file
			@rsa_public = OpenSSL::PKey::RSA.new File.read(File.join(Rails.root, 'config', 'public.pem'))
			@rsa_private = OpenSSL::PKey::RSA.new File.read(File.join(Rails.root, 'config', 'key.pem'))
		end

	end
end