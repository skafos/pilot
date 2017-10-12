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
  - conn: HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.
  - data: Struct to be encoded to JSON as the response body.
  - opts: Keyword list of options, supports
          - resp_headers: Map or list of 2-tuple response headers
                          to be added to the response

  ## Example
      conn |> json(:ok, %{hello: "World"})
      conn |> json(:ok, %{hello: "World"}, resp_headers: %{"x-foo" => "bar"})
  """
  def json(conn, status, data, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_json(conn, status, data, resp_headers)
  end
  defp do_json(conn, status, data, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Poison.encode_to_iodata!(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends an HTML response

  ## Parameters
  - conn: HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.
  - data: HTML string set as the response body.
  - opts: Keyword list of options, supports
          - resp_headers: Map or list of 2-tuple response headers
                          to be added to the response

  ## Example
      conn |> html("<h1>Hello World</h1>")
      conn |> html(:ok, "<h1>Hello World</h1>", resp_headers: %{"x-foo" => "bar"})
  """
  def html(conn, status, data, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_html(conn, status, data, resp_headers)
  end
  defp do_html(conn, status, data, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(status, to_string(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends an HTML response

  ## Parameters
  - conn: HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.
  - data: Text string set as the response body.
  - opts: Keyword list of options, supports
          - resp_headers: Map or list of 2-tuple response headers
                          to be added to the response

  ## Example
      conn |> text(:ok, "Hello World!")
      conn |> text(:ok, "Hello World!", resp_headers: %{"x-foo" => "bar"})
  """
  def text(conn, status, data, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_text(conn, status, data, resp_headers)
  end
  defp do_text(conn, status, data, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(status, to_string(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a status _only_ response

  ## Parameters
  - conn:   HTTP connection to send response to.
  - status: Atom or number that represents HTTP response code.
  - opts:   Keyword list of options, supports
            - resp_headers: Map or list of 2-tuple response headers
                            to be added to the response

  ## Example
      conn |> status(:ok)
  """
  def status(conn, status, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_status(conn, status, resp_headers)
  end
  defp do_status(conn, status, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.send_resp(status, "")
    |> Plug.Conn.halt()
  end

  @doc """
  Redirects request.

  ## Parameters
  - conn: HTTP connection to redirect.
  - status: Atom or number that represents HTTP response code.
  - url:  String representing URL/URI destination.

  ## Example
      conn |> redirect("http://<foo>.com/")
      conn |> redirect(301, "http://<foo>.com/")
  """
  def redirect(conn, status \\ 302, url) do
    conn
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(status, "")
    |> Plug.Conn.halt()
  end
end
