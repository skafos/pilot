defmodule User do
  require Logger

  use Router

  def route(conn, "GET", ["users", user_id]) do
    conn
    |> Plug.Conn.send_resp(200, "User id #{user_id}")
  end
end

defmodule Pilot do
  require Logger

  use Router

  def start(_, _), do: :ok

  def route(conn, "GET", ["hello"]) do
    conn
    |> Plug.Conn.send_resp(200, "Hello World!")
  end

  @user_options User.init([])
  def route(conn, "GET", ["users", _path]) do
    User.call(conn, @user_options)
  end

  def route(conn, _method, _path) do
    conn
    |> Plug.Conn.send_resp(200, "Default action")
  end
end
