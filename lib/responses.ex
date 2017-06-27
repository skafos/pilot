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
  - data: Struct to be encoded to JSON as the response body.
  - opts: Keyword list of options, supports
          - status: Atom or number that represents HTTP response code.
          - resp_headers: Map or list of 2-tuple response headers
                          to be added to the response

  ## Example
      conn |> json(%{hello: "World"})
  """
  def json(conn, data, opts \\ []) do
    status = Keyword.get(opts, :status, :ok)
    resp_headers = Keyword.get(opts, :resp_headers, [])
    json(conn, data, status, resp_headers)
  end
  defp json(conn, data, status, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Poison.encode_to_iodata!(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a HTML response

  ## Parameters
  - conn: HTTP connection to send response to.
  - data: HTML string set as the response body.
  - opts: Keyword list of options, supports
          - status: Atom or number that represents HTTP response code.
          - resp_headers: Map or list of 2-tuple response headers
                          to be added to the response

  ## Example
      conn |> html("<h1>Hello World</h1>")
  """
  def html(conn, data, opts \\ []) do
    status = Keyword.get(opts, :status, :ok)
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_html(conn, data, status, resp_headers)
  end
  defp do_html(conn, data, status, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(status, to_string(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a HTML response

  ## Parameters
  - conn: HTTP connection to send response to.
  - data: Text string set as the response body.
  - opts: Keyword list of options, supports
          - status: Atom or number that represents HTTP response code.
          - resp_headers: Map or list of 2-tuple response headers
                          to be added to the response

  ## Example
      conn |> text("Hello World!")
  """
  def text(conn, data, opts \\ []) do
    status = Keyword.get(opts, :status, :ok)
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_text(conn, data, status, resp_headers)
  end
  defp do_text(conn, data, status, resp_headers) do
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
  - url:  String representing URL/URI destination.
  - opts: Keyword list of options, supports
          - status: Atom or number that represents HTTP response code.
          - resp_headers: Map or list of 2-tuple response headers
                          to be added to the response

  ## Example
      conn |> redirect("http://<foo>.com/")
  """
  def redirect(conn, url, opts \\ []) do
    status = Keyword.get(opts, :status, 302)
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_redirect(conn, url, status, resp_headers)
  end
  defp do_redirect(conn, url, status, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(status, "")
    |> Plug.Conn.halt()
  end
end
