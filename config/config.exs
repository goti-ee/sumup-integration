import Config

config :sumup_integration,
  enabled_auto_exit?: false,
  ecto_repos: [SumupIntegration.Repo]

config :logger, :console, metadata: :all

config :sumup_integration, SumupIntegration.Worker, auto_fetch?: false

import_config "#{config_env()}.exs"
