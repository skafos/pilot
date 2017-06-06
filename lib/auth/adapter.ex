defmodule Pilot.Auth.Adapter do
  @moduledoc """
  Specification for authentication adapter
  """

  @type t       :: module
  @type params  :: Map.t
  @typep config :: Keyword.t

  @doc """
  Creates authorization based on given config.
  """
  @callback auth_create(params, config) :: String.t | nil

  @doc """
  Creates verification based on given config.
  """
  @callback auth_verify(Plug.Conn, config) :: {:ok, String.t} | {:error, String.t}

end