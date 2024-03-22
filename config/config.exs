import Config

config :sumup_integration,
  ecto_repos: [SumupIntegration.Repo]

config :logger, :console, metadata: :all

import_config "#{config_env()}.exs"
