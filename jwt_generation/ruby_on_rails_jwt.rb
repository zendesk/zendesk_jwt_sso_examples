# Using JWT from Ruby is straight forward. The below example expects you to have `jwt`
# in your Gemfile, you can read more about that gem at https://github.com/jwt/ruby-jwt.
# Assuming that you've set your shared secret and Zendesk subdomain in the environment, you
# can use Zendesk SSO from your controller like this example.
require 'jwt'
require 'securerandom' unless defined?(SecureRandom)

ZENDESK_SHARED_SECRET = ENV['ZENDESK_SHARED_SECRET']
ALGORITHM = 'HS256'.freeze

def generate_jwt(name, email)
  iat = Time.now.to_i
  header_fields = { typ: 'JWT' }

  payload = {
    iat: iat, # Seconds since epoch, determine when this token is stale
    jti: "#{iat}/#{SecureRandom.hex(18)}", # Unique token id, helps prevent replay attacks
    name: name,
    email: email
  }

  JWT.encode(payload, ZENDESK_SHARED_SECRET, ALGORITHM, header_fields)
end
