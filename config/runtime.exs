import Config

if config_env() != :test do
  config :sumup_integration, SumupIntegration.Sales.ApiTransaction,
    transactions_req_options: [
      auth: {:bearer, System.fetch_env!("GOTI_SUMUP_API_KEY")}
    ],
    transaction_req_options: [
      auth: {:bearer, System.fetch_env!("GOTI_SUMUP_API_KEY")}
    ]
end
