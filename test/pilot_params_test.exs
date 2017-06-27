defmodule Pilot.Tests.Params do
  require Logger
  import Plug.Test

  use ExUnit.Case

  alias Pilot.Tests.MockRouter

  doctest Pilot.Params

  test "converts map keys to atoms and merges with itself" do
    pre   = %{"one" => 1, "foo" => "bar", "hello" => "world"}
    post  = Map.merge(pre, %{one: 1, foo: "bar", hello: "world"})

    assert Pilot.Params.update(pre) == post
  end

  test "converts map keys to atoms for nested maps" do
    pre   = %{"one" => 1, "foo" => "bar", "nested" => %{"hello" => "world"}}
    post  = Map.merge(pre, %{one: 1, foo: "bar", nested: %{hello: "world"}})

    assert Pilot.Params.update(pre) == post
  end

  test "converts map keys to atoms for nested lists" do
    pre   = %{"one" => 1, "foo" => "bar", "nested" => [%{"hello" => "world"}, %{"goodbye" => "earth"}]}
    post  = Map.merge(pre, %{one: 1, foo: "bar", nested: [%{hello: "world"}, %{goodbye: "earth"}]})

    assert Pilot.Params.update(pre) == post
  end

  test "Ignore non-map terms." do
    pre   = %{"list" => [1, 2, %{"foo" => "bar"}]}
    post  = Map.merge(pre, %{list: [1, 2, %{foo: "bar"}]})

    assert Pilot.Params.update(pre) == post
  end

  @opts MockRouter.init([])
  test "Request params have both atom and string keys" do
    params = :get |> conn("/test/wess/jer/david")
                  |> MockRouter.call(@opts)
                  |> Map.get(:params)

    assert params[:foo] == "wess"
    assert params[:bar] == "jer"
    assert params[:baz] == "david"

    assert params["foo"] == "wess"
    assert params["bar"] == "jer"
    assert params["baz"] == "david"
  end

end
