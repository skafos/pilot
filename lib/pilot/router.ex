defmodule Router do
  defmacro __using__(_opts) do
    quote do
      def init(options), do: options

      def call(conn, _opts) do
        route(conn, conn.method, conn.path_info)
      end
      
    end
  end
end