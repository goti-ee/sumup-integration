import Config

config :sumup_integration,
  ecto_repos: [SumupIntegration.Repo]

config :sumup_integration, Oban,
  repo: SumupIntegration.Repo,
  queues: [default: 10]

config :sumup_integration, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # Run every 10 minutes
       {"*/10 * * * *", SumupIntegration.Worker}
     ]}
  ]

config :logger, :console, metadata: :all

config :sumup_integration, SumupIntegration.Worker, auto_fetch?: true

import_config "#{config_env()}.exs"
