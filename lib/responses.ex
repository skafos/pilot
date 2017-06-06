defmodule Pilot.Responses do
  @moduledoc """
    Plug HTTP Response wrappers.
  """

  require Logger

  defmacro __using__(_) do
    quote do
      import Plug.Conn
      import unquote(__MODULE__) 
    end
  end

  @doc """
  Sends a JSON response
  
  ## Parameters
  - conn:   HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.
  - data:   Struct to be encoded to JSON as the response body.

  ## Example
      conn |> json(:ok, %{hello: "World"})
  """
  def json(conn, status, data) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Poison.encode_to_iodata!(data))    
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a HTML response
  
  ## Parameters
  - conn:   HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.
  - data:   HTML string set as the response body.

  ## Example
      conn |> html(:ok, "<h1>Hello World</h1>")
  """
  def html(conn, status, data) do
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(status, to_string(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a HTML response
  
  ## Parameters
  - conn:   HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.
  - data:   Text string set as the response body.

  ## Example
      conn |> text(:ok, "Hello World!")
  """
  def text(conn, status, data) do
    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(status, to_string(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a status _only_ response
  
  ## Parameters
  - conn:   HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.

  ## Example
      conn |> status(:ok)
  """
  def status(conn, status) do
    conn
    |> Plug.Conn.send_resp(status, "")
    |> Plug.Conn.halt()
  end

  @doc """
  Redirects request.

  ## Parameters
  - conn:   HTTP connection to redirect.
  - url:    String representing URL/URI destination.
  - status: Atom or number that represents HTTP response code.

  ## Example
      conn |> redirect("http://metismachine.com/")
  """
  def redirect(conn, url, status \\ 302) do
    conn
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(status, "")
    |> Plug.Conn.halt()
  end
end
