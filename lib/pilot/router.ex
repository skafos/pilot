defmodule Pilot.Router do
  require Logger

  alias Pilot.Router.Utils
  alias Pilot.Router.Response

  defmacro __using__(_opts) do
    quote do
      import Pilot.Router
      import Plug.Builder, only: [plug: 1, plug: 2]
      import Plug.Conn

      @behaviour Plug
      @builder_options []

      Module.register_attribute(__MODULE__, :plugs, accumulate: true)

      default_routing = [
        "Elixir.Pilot.LiveReload":  [env: Mix.env],
        "Elixir.Plug.Logger":       [],
      ]

      @static_path  Path.relative_to_cwd(Application.get_env(:pilot, :static_route, "public"))
      @root_path    "/"

      default_routing
      |> Enum.each(fn({router, args}) -> plug(router, args) end)

      def init(opts) do
        opts
      end

      def call(conn, opts) do
        plug_builder_call(conn, opts)
      end

      def match(conn = %Plug.Conn{state: :unset}, _opts) do
        spec = conn.req_headers
               |> Enum.into(%{})
               |> Map.merge(conn.assigns)
               |> Map.put(:host, conn.host)

        action = execute_match(conn.method, conn.path_info |> Enum.map(&URI.decode/1), spec)
        action.(conn)
      end

      def match(conn, _opts) do
        conn
      end

      plug :match

      @before_compile Pilot.Router
      @before_compile Plug.Builder
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def execute_match(_method, _path, _spec) do
        # Allows pass thru so plug won't die if there is more plugs after this.
        fn(conn) -> conn end
      end
    end
  end

  def __route__(method, path, guards, options) do
    {method, guards}  = Utils.build_methods(List.wrap(method || options[:via]), guards)
    {_, match}        = Plug.Router.Utils.build_path_match(path)

    {method, match, guards}
  end

  defmacro mount(module) do
    quote do
      defp mount_match(conn, [module: unquote(module)]) do
        unquote(module).match(conn, [])
      end

      plug :mount_match, module: unquote(module)
    end
  end

  defmacro match(path, options, contents),          do: compile(nil, path, options, contents)
  defmacro get(path, options, contents \\ []),      do: compile(:get, path, options, contents)
  defmacro post(path, options, contents \\ []),     do: compile(:post, path, options, contents)
  defmacro put(path, options, contents \\ []),      do: compile(:put, path, options, contents)
  defmacro patch(path, options, contents \\ []),    do: compile(:patch, path, options, contents)
  defmacro delete(path, options, contents \\ []),   do: compile(:delete, path, options, contents)
  defmacro options(path, options, contents \\ []),  do: compile(:options, path, options, contents)
  
  defmacro redirect(from, to), do: compile(:get, from, [], do: quote do: {:redirect, unquote(to)})
  
  defmacro static(path, route), do: plug_static(path, route)
  defmacro static(path),        do: plug_static(path, "/")

  defmacro namespace(path, options) do
    quote bind_quoted: [path: path, options: options] do
      {target, options} = Keyword.pop(options, :to)
      {options, plug_options} = Keyword.split(options, [:host, :private, :assigns])
      plug_options = Keyword.get(plug_options, :init_opts, plug_options)

      if is_nil(target) or !is_atom(target) do
        raise ArgumentError, message: "expected :to to be an alias or an atom"
      end

      @target_namespace target
      @target_opts      target.init(plug_options)

      match path <> "/*glob", options do
        Pilot.Router.Utils.namespace(
          var!(conn),
          var!(glob),
          @target_namespace,
          @target_opts
        )
      end

    end
  end

  defp plug_static(path, route) do
    quote do
      static_path = Path.join(@static_path, unquote(route))

      @plugs {Plug.Static, [at: unquote(path), from: route], true}
    end
  end

  defp compile(method, expr, options, contents) do
    {body, options} =
      cond do
        Keyword.has_key?(contents, :do) ->
          {contents[:do], options}
        Keyword.has_key?(options, :do) ->
          Keyword.pop(options, :do)
        Keyword.has_key?(options, :to) ->
          {to, options} = Keyword.pop(options, :to)
          {init_opts, options} = Keyword.pop(options, :init_opts, [])
          body =
            quote do
              @plug_router_to.call(var!(conn), @plug_router_init)
            end
          options =
            quote do
              to = unquote(to)
              @plug_router_to to
              @plug_router_init to.init(unquote(init_opts))
              unquote(options)
            end
          {body, options}
        true ->
          raise ArgumentError,  message: "expected one of :to or :do to be given as an option"
      end
    
    options = options |> Utils.sanitize_options()

    quote bind_quoted: [
      method:   method,
      options:  options,
      expr:     expr,
      body:     Macro.escape(body, unquote: true)
    ] do
      path                    = Path.join(@root_path, expr)
      {path, guards}          = Utils.extract_path_guards(path)
      {method, match, guards} = Pilot.Router.__route__(method, path, guards, options)

      params = %{} 
      |> Utils.build_headers_match(options[:headers])
      |> Utils.build_host_match(options[:host])
      |> Macro.escape

      def execute_match(unquote(method), unquote(match), unquote(params)) when unquote(guards) do
        fn var!(conn) ->
          unquote(body)
          |> Response.make(var!(conn))
        end
      end
    end
  end
end
