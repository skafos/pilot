defmodule Pilot do
  defmacro __using__(_) do
    quote location: :keep do
      import Plug.Conn

      use Plug.Router
      use Plug.ErrorHandler
      use Pilot.Responses

      import unquote(__MODULE__)

      plug Plug.Parsers, 
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Poison
    end
  end
end

