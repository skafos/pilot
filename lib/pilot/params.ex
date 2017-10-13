defmodule Pilot.Params do
  @moduledoc """
  Improves the quality of request parameters.
  """

  @doc false
  @spec init(term :: term) :: :ok
  def init(_), do: :ok

  @doc """
  Plug's `call` callback. It calls `update_params/1` method on the param map
  from `Plug.Conn` so they are available as string and atom keys.
  """
  @spec call(conn :: Plug.Conn.t, :ok) :: Plug.Conn.t
  def call(%{params: params} = conn, :ok) do
    %{conn | params: params |> update()}
  end

  @doc """
  Takes a map with string keys and returns a map with atom keys
  along with the string keys, including nested items.

  ## Parameters
  - map: Map of keys/value from Plug.conn parameters.

  ## Example
      map = %{"one" => 1, "foo" => "bar", "baz" => %{"hello" => "world"}}
      Pilot.Params.update(map)

      # => %{:one => 1, :foo => "bar", :baz => %{:hello => "world"}}
  """
  @spec update(map :: map) :: map
  def update(map) when is_map(map) do
    map
    |> Map.delete(:__struct__)
    |> convert()
    |> Map.merge(map)
  end

  defp convert(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {k, v}, m ->
      put(m, k, convert(v))
    end)
  end

  defp convert(list) when is_list(list) do
    Enum.map(list, &convert/1)
  end

  defp convert(term), do: term

  defp put(map, key, val) when is_map(map) do
    try do
      cond do
        is_binary(key) ->
          Map.put(map, String.to_existing_atom(key), val)
        true ->
          Map.put(map, key, val)
      end
    rescue
      ArgumentError -> map
    end
  end
end
