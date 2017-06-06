defmodule Pilot.Auth.JWT do
  @moduledoc """
  JWT (JSON Web Token) Auth handler.
  """
  import Plug.Conn
  import Pilot.Responses
  require Logger
  
  @behaviour Pilot.Auth.Adapter

  @doc """
  Creates a new JWT based on given properties

  ## Parameters
  - params: Map of properties (and values) used to create a token

  ## Example
      Pilot.Auth.JWT.create(%{username: "wess", id: "1"})
  """
  def auth_create(params, config \\ :pilot) do
    secret = Application.get_env(config, :auth_secret)
    
    params
    |> Joken.token()
    |> Joken.with_signer(Joken.hs256(secret))
    |> Joken.sign()
    |> Joken.get_compact()
  end

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
  def auth_verify(conn, config \\ :pilot) do
    case jwt_verify(conn |> auth_header_token, config) do
      {:ok, _token} ->
        conn
      {:error, error} ->
        conn
        |> json(:unauthorized, %{error: error})
      _ ->
        conn
    end
  end

  defp jwt_verify(payload, config) do
    secret = Application.get_env(config, :auth_secret)

    jwt = payload
          |> Joken.token()
          |> Joken.with_signer(Joken.hs256(secret))
          |> Joken.verify

    case jwt.error do
      nil ->
        {:ok, payload}
      _ ->
        {:error, jwt.error}
    end
  end

  defp auth_header_token(conn) do
    get_req_header(conn, "authorization") 
    |> header_token
  end
  
  defp header_token(["Bearer " <> token]), do: token
  defp header_token(_), do: nil

end