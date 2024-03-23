import Config

config :sumup_integration,
  enabled_auto_exit?: true,
  ecto_repos: [SumupIntegration.Repo]

config :sumup_integration, SumupIntegration.Worker, auto_fetch?: true
