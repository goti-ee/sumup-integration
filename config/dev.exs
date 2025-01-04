import Config

config :sumup_integration, SumupIntegration.Repo,
  database: "sumup_integration",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :opentelemetry, traces_exporter: :none
