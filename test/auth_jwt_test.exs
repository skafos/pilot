defmodule PilotAuthJWTTest do
  require Logger
  use ExUnit.Case

  import Plug.Conn
  import Plug.Test
  
  alias Pilot.Auth.JWT

  test "ensure a jwt token is created" do
    token = JWT.auth_create(%{username: "wess", user_id: 1})

    assert token != nil
  end

  test "verify jwt token" do
    token   = JWT.auth_create(%{username: "wess", user_id: 1})
    result  = test_conn() |> create_auth_header(token) |> JWT.auth_verify()

    assert result.status != 401
  end

  defp create_auth_header(conn, token) do
    conn
    |> put_req_header("authorization", "Bearer #{token}")    
  end

  defp test_conn(method \\ :get, path \\ "/path") do
    conn(method, path)
  end

end