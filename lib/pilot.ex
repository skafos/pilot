defmodule Pilot do
  require Logger
  use Application

  @http_methods [:get, :post, :put, :patch, :delete, :options,]
  @version      Mix.Project.config[:version]

  def version, do: @version

  def start(_type, args) do
    import Supervisor.Spec

    port    = args[:port] || 4000
    router  = args[:router]

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, router, [], [port: port]),
    ]

    Supervisor.start_link(children, [strategy: :one_for_one, name: Pilot.Supervisor])
  end

  defmacro is_method(spec) do
    quote do
      is_atom(unquote(spec)) and unquote(spec) in unquote(@http_methods)
    end
  end

  def parse_query(string) do
    string
    |> URI.query_decoder
    |> Enum.reverse
    |> Enum.reduce([], &decode(&1, &1))
  end

  defp decode({key, nil}, collection) do
    collection
    |> Keyword.put(String.to_atom(key), true)
  end

  defp decode({key, val}, collection) do
    case Poison.decode(val) do
      {:ok, decoded} -> 
        collection |> Keyword.put(String.to_atom(key), decoded)
      {:error, _} ->
        collection |> Keyword.put(String.to_atom(key), val)
    end
  end
end

