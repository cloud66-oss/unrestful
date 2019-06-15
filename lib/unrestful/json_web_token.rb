# frozen_string_literal: true
require 'net/http'
require 'uri'

module Unrestful 
	class JsonWebToken
		ISSUER = 'https://cloud66.eu.auth0.com/'
		LEEWAY = 30
		AUDIENCE = ['central.admin.api.v2.development']

		def self.verify(token)
			JWT.decode(token, nil,
					true,
					algorithm: 'RS256',
					iss: ISSUER,
					verify_iss: true,
					aud: AUDIENCE,
					verify_aud: true) do |header|
						jwks_hash[header['kid']]
					end
		end

		def self.jwks_hash
			jwks_raw = Net::HTTP.get URI("#{ISSUER}.well-known/jwks.json")
			jwks_keys = Array(JSON.parse(jwks_raw)['keys'])
			Hash[
				jwks_keys.map do |k|
					[
						k['kid'],
						OpenSSL::X509::Certificate.new(Base64.decode64(k['x5c'].first)).public_key
					]
				end
			]
		end
	end
end