use Mix.Config

config :pilot,
  secret: "some-secret-goes-here",
  adapter: Pilot.Auth.JWT