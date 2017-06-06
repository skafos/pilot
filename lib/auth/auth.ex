defmodule Pilot.Auth do
  @moduledoc """
  Handles creating and verifiying authentication for endpoints.
  """

  require Logger
  import Plug.Conn
  use Pilot.Responses

  alias Pilot.Auth.JWT

  @doc false
  def init(opts \\ []) do
    Keyword.get(opts, :verify, :json)
  end
  
  @doc false
  def call(conn, _opts) do
    if Map.has_key?(conn.private, :auth_required) do
      verify(conn)
    else
      Logger.info "Has No Key"
      conn
    end
  end

  @doc """
  Creates authorization based on provided type
  
  ## Parameters
  - conn: Current Plug.Conn (request)
  - params: Params to use for authentication

  ## Example
      post "/" do
        case get_user(conn.params["username"], conn.params["password"]) do
          {:ok, user} ->
            json(:ok, %{token: Pilot.Auth.create(%{user_id, user.id})})
          _->
            json(:unauthorized, %{error: "Invalid user"})
        end
      end
  """
  def create(_conn, params) do
    JWT.create(params)
  end

  @doc """
  Verifies authentication based on provided type.

  ## Parameters
  - conn: Current Plug.Conn (request)

  ## Example
      get "/", private: %{auth_required: true} do
        json(:ok, %{hello: "world"})
      end
  """
  def verify(conn) do
    case JWT.verify(conn |> auth_header_token) do
      {:ok, _token} ->
        conn
      {:error, error} ->
        conn
        |> json(:unauthorized, %{error: error})
      _ ->
        conn
      
    end
  end

  defp auth_header_token(conn) do
    get_req_header(conn, "authorization") 
    |> header_token
  end
  
  defp header_token(["Bearer " <> token]), do: token
  defp header_token(_), do: nil
end
