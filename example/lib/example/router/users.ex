defmodule Example.Router.Users do
  use Pilot.Router
  
  get "/" do
    "Hello from Users!"
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
