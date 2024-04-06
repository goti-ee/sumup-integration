import Config

config :sumup_integration,
  ecto_repos: [SumupIntegration.Repo]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :sumup_integration, Oban,
  repo: SumupIntegration.Repo,
  queues: [default: 10]

config :logger, :console, metadata: :all

config :sumup_integration, SumupIntegration.Pipeline.TimestampLocalization,
  time_zone: "Europe/Tallinn"

import_config "#{config_env()}.exs"
