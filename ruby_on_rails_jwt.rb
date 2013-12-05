# Using JWT from Ruby is straight forward. The below example expects you to have `jwt`
# in your Gemfile, you can read more about that gem at https://github.com/progrium/ruby-jwt.
# Assuming that you've set your shared secret and Zendesk subdomain in the environment, you
# can use Zendesk SSO from your controller like this example.
require 'securerandom' unless defined?(SecureRandom)

class ZendeskSessionController < ApplicationController
  # Configuration
  ZENDESK_SHARED_SECRET = ENV["ZENDESK_SHARED_SECRET"]
  ZENDESK_SUBDOMAIN     = ENV["ZENDESK_SUBDOMAIN"]

  def create
    if user = User.authenticate(params[:login], params[:password])
      # If the submitted credentials pass, then log user into Zendesk
      sign_into_zendesk(user)
    else
      render :new, :notice => "Invalid credentials"
    end
  end

  private

  def sign_into_zendesk(user)
    # This is the meat of the business, set up the parameters you wish
    # to forward to Zendesk. All parameters are documented in this page.
    iat = Time.now.to_i
    jti = "#{iat}/#{SecureRandom.hex(18)}"

    payload = JWT.encode({
      :iat   => iat, # Seconds since epoch, determine when this token is stale
      :jti   => jti, # Unique token id, helps prevent replay attacks
      :name  => user.name,
      :email => user.email,
    }, ZENDESK_SHARED_SECRET)

    redirect_to zendesk_sso_url(payload)
  end

  def zendesk_sso_url(payload)
    "https://#{ZENDESK_SUBDOMAIN}.zendesk.com/access/jwt?jwt=#{payload}"
  end
end
