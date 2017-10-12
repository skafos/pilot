defmodule Example.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Example.Pilot, [])
    ]

    opts = [strategy: :one_for_one, name: Example.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
