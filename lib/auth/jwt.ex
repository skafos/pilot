defmodule Pilot.Auth.JWT do
  @moduledoc """
  JWT (JSON Web Token) Auth handler.
  """

  require Logger
  
  @auth_secret Application.get_env(:pilot, :auth_secret)

  @doc """
  Verifies provided token

  ## Parameters
  - payload: String token to verify.

  ## Example
      case Pilot.Auth.JWT.verify("my-token") do
        {:ok, token} -> 
          token
        {:error, error} ->
          error
      end
  """
  def verify(payload) do
    signed = Joken.hs256(@auth_secret)

    jwt = payload
          |> to_string()
          |> Joken.token()
          |> Joken.with_signer(signed)
          |> Joken.verify

    case jwt.error do
      nil ->
        {:ok, payload}
      _ ->
        {:error, jwt.error}
    end
  end

  @doc """
  Creates a new JWT based on given properties

  ## Parameters
  - params: Map of properties (and values) used to create a token

  ## Example
      Pilot.Auth.JWT.create(%{username: "wess", id: "1"})
  """
  def  create(params) do
    params
    |> Joken.token()
    |> Joken.with_signer(Joken.hs256(@auth_secret))
    |> Joken.sign()
    |> Joken.get_compact()
  end
end