import Config

config :logger, level: :info

config :sumup_integration,
  ecto_repos: [SumupIntegration.Repo]

config :sumup_integration, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # Run every 10 minutes
       {"*/10 * * * *", SumupIntegration.Worker, args: %{"type" => "incremental"}},
       {"@daily", SumupIntegration.Worker, args: %{"type" => "last-month"}},
       {"@weekly", SumupIntegration.Worker, args: %{"type" => "full"}}
     ]}
  ]
