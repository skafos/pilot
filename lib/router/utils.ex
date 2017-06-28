defmodule Pilot.Router.Utils do
  ## Borrowed from Plug.Router.Utils

  def normalize_method(method) do
    method
    |> to_string
    |> String.upcase
  end

  def normalize_header(header) do
    header
    |> to_string
    |> String.downcase
  end

  def sanitize_header({key, value}) do
    {key |> to_string |> String.downcase, value}
  end

  def sanitize_options(options) do
    options
    |> Enum.map(&default_keyword/1)
  end

  def build_host_match(host) do
    %{}
    |> build_host_match(host)
  end

  def build_host_match(spec, nil) do
    spec
  end

  def build_host_match(spec, host) do
    spec
    |> Map.put(:host, host)
  end

  def build_headers_match(spec) do
    build_headers_match(%{}, spec)
  end

  def build_headers_match(spec, nil) do
    spec
  end

  def build_headers_match(spec, headers) do
    headers
    |> Enum.map(fn({key, value}) -> {normalize_header(key), value} end)
    |> Enum.into(%{})
    |> Map.merge(spec)
  end

  def extract_path_guards({:when, _, [path, guards]}) do
    {extract_path(path), guards}
  end

  def extract_path_guards(path) do
    {extract_path(path), true}
  end

  ### Private
  def extract_path({:_, _, var}) when is_atom(var), do: "/*_path"
  def extract_path(path), do: path

  def build_methods([], guards) do
    {quote(do: _), guards}
  end

  def build_methods([method], guards) do
    {normalize_method(method), guards}
  end

  def build_methods(methods, guards) do
    methods = methods |> Enum.map(&normalize_method(&1))
    var     = quote do: method
    guards  = join(quote(do: unquote(var) in unquote(methods)), guards)

    {var, guards}
  end

  defp join(index, true) do
    index
  end

  defp join(index, step) do
    (quote do: unquote(index) and unquote(step))
  end

  defp default_keyword(default = {_key, _value}), do: default
  defp default_keyword(key) when is_atom(key), do: {key, true}
end
