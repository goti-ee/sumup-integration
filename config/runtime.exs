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

config :opentelemetry_exporter,
  otlp_protocol: :http_protobuf,
  otlp_endpoint: "https://api.honeycomb.io:443",
  otlp_headers: [
    {"x-honeycomb-team", System.fetch_env!("HONEYCOMB_API_KEY")}
  ]
