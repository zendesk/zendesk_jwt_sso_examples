#!/usr/bin/env elixir
Mix.install([
  {:jose, "~> 1.11"},
  {:jason, "~> 1.4"}
])

defmodule Zendesk do
  def jwt(email, name, shared_key) do
    jwk = JOSE.JWK.from_oct(shared_key)

    payload = %{
      iat: System.os_time(:second),
      jti: 30 |> :crypto.strong_rand_bytes() |> Base.encode64(),
      email: email,
      name: name
    }

    JOSE.JWT.sign(jwk, %{"alg" => "HS256"}, payload) |> JOSE.JWS.compact() |> elem(1)
  end
end

# Represents the shared key generated from the Zendesk SSO Admin UI
shared_key = 36 |> :crypto.strong_rand_bytes() |> Base.url_encode64()
jwt = Zendesk.jwt("apd@example.com", "Arthur Philip Dent", shared_key)

IO.puts("Example JWT:\n#{jwt}\n\nVerify with shared key:\n#{shared_key}")
