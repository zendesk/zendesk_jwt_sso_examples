class JwtController < ApplicationController
  ...
  ZENDESK_SUBDOMAIN = ENV['ZENDESK_SUBDOMAIN']
  # Zendesk will pass various params when redirecting you to your remote login URL
  JWT_PARAMS = %i[return_to brand_id locale_id timestamp].freeze
  ...

  def create
    if (user = User.authenticate(params[:login], params[:password]))
      # Use your implemented JWT generation code. See ../jwt_generation/ruby_on_rails_jwt.rb for an example
      @jwt = generate_jwt(user.name, user.email)
      # handle any JWT generation errors

      jwt_params = params.slice(*JWT_PARAMS).permit(*JWT_PARAMS)
      # Ensure parameters that Zendesk passed to your remote login page are preserved
      @url = "https://#{ZENDESK_SUBDOMAIN}.zendesk.com/access/jwt?#{jwt_params.to_query}"

      render :create
    else
      render :new, notice: 'Invalid credentials'
    end
  end
  ...
end

# jwt/create.html.erb
<%= javascript_tag do %>
  window.onload = function(){
    document.forms['jwt_form'].submit();
  }
<% end %>

<%= form_with url: @url, html: { id: 'jwt_form' } do |f| %>
    <%= f.hidden_field :jwt, value: @jwt %>
<% end %>
