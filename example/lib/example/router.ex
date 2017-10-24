defmodule Example.Router do
  use Pilot.Router

  namespace "/users", to: Example.Router.Users

  get "/hello" do
    "Hello from Router!"
  end
end
