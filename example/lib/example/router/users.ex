defmodule Example.Router.Users do
  use Pilot.Router
  
  get "/hello" do
    "Hello from Users!"
  end
end
