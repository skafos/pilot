defmodule Pilot.Router.Response do
  require Logger
  import Plug.Conn

  alias Pilot.Router.Utils

  def make(%Plug.Conn{state: :set}, _conn) do 
    raise ArgumentError, message: "Send Conn before returning"
  end

  def make(conn = %Plug.Conn{}, _conn) do
    conn
  end

  def make({:redirect, to}, conn) do
    make_redirect(to, conn)
  end

  def make({:badrpc, {:EXIT, {reason, _metadata}}}, conn) do
   Logger.warn "Bad RPC error: #{inspect reason}"

   {:internal_server_error, inspect(reason)}
   |> make(conn) 
  end

  def make({:badrpc, reason}, conn) do
   Logger.warn "Bad RPC error: #{inspect reason}"

   {:internal_server_error, inspect(reason)}
   |> make(conn) 
  end

  def make(body, conn) when is_binary(body) do
    {:ok, body}
    |> make(conn)
  end

  def make(statusCode, conn) when is_number(statusCode) do
    {statusCode, ""}
    |> make(conn)
  end

  def make(statusCode, conn) when is_number(statusCode) do
    {statusCode, ""}
    |> make(conn)
  end

  def make(statusCode, conn) when is_atom(statusCode) do
    {Plug.Conn.Status.code(statusCode), ""}
    |> make(conn)
  end

  def make({code, body}, conn) when is_atom(code) do
    {Plug.Conn.Status.code(code), body}
    |> make(conn)
  end

  def make({code, body}, conn) when is_number(code) and is_binary(body) do
    conn
    |> Plug.Conn.send_resp(code, body)
  end

  def make({code, body, headers}, conn) do
    conn = headers  |> Enum.map(&Utils.sanitize_header/1)
                    |> Enum.reduce(conn, fn({key, value}, conn) -> Plug.Conn.put_resp_header(conn, key, value) end)

    {code, body}
    |> make(conn)
  end

  def make({code, body}, conn) when is_number(code) do
    {code, Poison.encode(body)}
    |> make(conn)
  end
  
  def make(body, conn) do
    {:ok, Poison.encode!(body)}
    |> make(conn)
  end

  ### Private

  defp make_redirect(path, conn) when is_binary(path) do
    conn
    |> Plug.Conn.put_resp_header("location", path)
    |> Plug.Conn.send_resp(Plug.Conn.Status.code(:temporary_redirect), "")
  end

  defp make_redirect(uri = %URI{}, conn) do
    uri
    |> to_string
    |> make_redirect(conn)
  end
end
