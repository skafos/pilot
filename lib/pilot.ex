defmodule Pilot do
  require Logger
  @moduledoc """
  Defines a Pilot api endpoint

  When used, the endpoint expects `:otp_app` as an option. The `:otp_app`
  should point to an OTP application that has the endpoint configuration.
  For example, the endpoint:

    defmodule Example.Pilot do
      use Pilot, otp_app: :example
    end

  Can be configured with:

    config :example, Example.Pilot,
      port:   8080,
      router: Example.Router


  ## Options

  The endpoint accepts the following options:

    * `:port` - Specfies the port to run the endpoint on
    * `:router` - The root router to use for all requests

  """

  @http_methods [:get, :post, :put, :patch, :delete, :options,]
  @version      Mix.Project.config[:version]

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Pilot

      {otp_app, config} = Pilot.Supervisor.config(__MODULE__, opts)

      @pilot_config   config
      @pilot_otp_app  otp_app

      def config do
        @pilot_config
      end

      def start_link(opts \\ []) do
        Pilot.Supervisor.start_link(__MODULE__, @pilot_config, opts)
      end
    end
  end

  @doc """
  Returns the endpoint configuration stored in the `:otp_app` environment
  """
  @callback config() :: Keyword.t

  @doc """
  Starts the endpoint supervisor
  """
  @callback start_link(opts :: Keyword.t) :: {:ok, pid}
                                           | {:error, {:already_started, pid}}
                                           | {:error, term}

  @doc false
  defmacro is_method(spec) do
    quote do
      is_atom(unquote(spec)) and unquote(spec) in unquote(@http_methods)
    end
  end

  @doc false
  def parse_query(string) do
    string
    |> URI.query_decoder
    |> Enum.reverse
    |> Enum.reduce([], &decode(&1, &1))
  end

  defp decode({key, nil}, collection) do
    collection
    |> Keyword.put(String.to_atom(key), true)
  end

  defp decode({key, val}, collection) do
    case Poison.decode(val) do
      {:ok, decoded} -> 
        collection |> Keyword.put(String.to_atom(key), decoded)
      {:error, _} ->
        collection |> Keyword.put(String.to_atom(key), val)
    end
  end
end
