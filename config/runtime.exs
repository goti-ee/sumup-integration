import Config

config :sumup_integration,
  sumup_api_key: System.fetch_env!("GOTI_SUMUP_API_KEY")
