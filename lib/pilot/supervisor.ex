defmodule Pilot.Supervisor do
  @moduledoc false

  use Supervisor

  require Logger

  @defaults [port: 8080]

  # Client API

  @doc """
  Returns the endpoint configuration stored in the `:otp_app` environment
  """
  def config(pilot, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  =
      @defaults
      |> Keyword.merge(Application.get_env(otp_app, pilot, []))
      |> Keyword.merge([otp_app: otp_app, pilot: pilot])

    case Keyword.get(config, :router) do
      nil ->
        raise ArgumentError, "missing :router configuration in " <>
                             "config #{inspect(otp_app)}, #{inspect(pilot)}"
      _ ->
        :ok
    end

    {otp_app, config}
  end

  @doc """
  Start the endpoint supervisor
  """
  def start_link(pilot, config, opts \\ []) do
    name = Keyword.get(opts, :name, pilot)
    Supervisor.start_link(__MODULE__, {pilot, config}, [name: name])
  end

  # Server API

  def init({_pilot, config}) do
    port    = Keyword.fetch!(config, :port)
    router  = Keyword.fetch!(config, :router)

    Logger.debug(fn -> "Starting pilot on port #{inspect(port)} " <>
                 "routing through #{inspect(router)}" end)

    children = [Plug.Adapters.Cowboy.child_spec(:http, router, [], [port: port])]
    supervise(children, strategy: :one_for_one)
  end
end
