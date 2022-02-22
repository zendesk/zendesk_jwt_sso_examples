defmodule ZendeskSso do
  # assumes you have the Joken JWT module:
  # https://github.com/joken-elixir/joken

  # assumes you have the UUID module:
  # https://hexdocs.pm/uuid/readme.html

  use Joken.Config

  def generate_zendesk_jwt_token(%User{} = user) do
    zendesk_config = Application.get_env(:zendesk)
    jwt_secret = Keyword.get(zendesk_config, :jwt_secret)
    algorithm = Keyword.get(zendesk_config, :algorithm)

    signer = Joken.Signer.create(algorithm, jwt_secret)

    jwt_params = %{
      iat: DateTime.utc_now(),
      jit: UUID.uuid4(),
      email: user.email,
      name: user.name
    }

    generate_and_sign!(jwt_params, signer)
  end

  # this assumes the session is already authenticated
  def authenticate_zendesk(conn, _params) do
    zendesk_config = Application.get_env(:zendesk)
    zendesk_subdomain = Keyword.get(zendesk_config, :subdomain)

    jwt_user_token = generate_zendesk_jwt_token(user)

    return_to =
      params
      |> Map.get("return_to", nil)
      |> case do
        nil ->
          nil

        return_to ->
          URI.encode_query(return_to)
      end

    redirect_location =
      "https://#{zendesk_subdomain}.zendesk.com/access/jwt?jwt=#{jwt_user_token}"

    redirect_location =
      if is_nil(return_to),
        do: redirect_location,
        else: "#{redirect_location}&return_to=#{return_to}"

    redirect(conn, external: redirect_location)
  end
end
