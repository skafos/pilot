defmodule Example.Router do
  use Pilot.Router

  namespace "/users", to: Example.Router.Users

  get "/hello" do
    "Hello from Router!"
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
