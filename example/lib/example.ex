defmodule Example do
  require Logger
  use Pilot.Router

  get "/test" do
    "Hello, World"
  end
end
