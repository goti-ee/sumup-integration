import Config

config :logger, level: :info

config :sumup_integration,
  ecto_repos: [SumupIntegration.Repo]

config :sumup_integration, SumupIntegration.Worker, auto_fetch?: true
