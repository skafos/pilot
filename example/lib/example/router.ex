defmodule Example.Router do
  use Pilot.Router

  get "/test" do
    "Hello, world!"
  end
end
