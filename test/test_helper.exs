defmodule Pilot.Tests.MockRouter do
  use Plug.Router
  
  plug :match
  plug :dispatch
  plug Pilot.Params

  get "/test/:foo/:bar/:baz" do
    conn |> send_resp(200, "response")
  end
end

# Run tests
ExUnit.start()
