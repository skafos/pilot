defmodule Pilot.LiveReload do
  import Plug.Conn
    
  @behaviour Plug

  def init(opts \\ []), do: opts

  def call(conn, _) do
    case reload(Mix.env) do
      :ok ->
        location = "/" <> conn.path_info |> Enum.join("/")
        conn
        |> put_resp_header("location", location)
        |> ensure_response_sent(302, "")

      _ ->
        conn
    end
  end

  defp reload(:dev), do: Mix.Tasks.Compile.Elixir.run([])
  defp reload(_), do: :noreload

  defp ensure_response_sent(%Plug.Conn{state: :sent} = conn, _, _) do
    conn
  end

  defp ensure_response_sent(conn, status, body) do
    conn
    |> send_resp(status, body)
  end
end
