defmodule Pilot.Auth do
  @moduledoc """
  Handles creating and verifiying authentication for endpoints.
  """

  require Logger
  import Plug.Conn
  use Pilot.Responses

  @adapter Application.get_env(:pilot, :adapter)

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
  defdelegate create(params), to: @adapter, as: :auth_create

  @doc """
  Verifies authentication based on provided type.

  ## Parameters
  - conn: Current Plug.Conn (request)

  ## Example
      get "/", private: %{auth_required: true} do
        json(:ok, %{hello: "world"})
      end
  """
  defdelegate verify(conn), to: @adapter, as: :auth_verify
end
