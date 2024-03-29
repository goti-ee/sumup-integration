import Config

config :sumup_integration, Oban, testing: :inline

config :logger, level: :warning

config :sumup_integration,
  testcontainers: true

config :sumup_integration, SumupIntegration.Repo, pool: Ecto.Adapters.SQL.Sandbox

config :sumup_integration, SumupIntegration.Sales.ApiTransaction,
  parallel?: false,
  transactions_req_options: [
    plug: {Req.Test, SumupIntegration.Sales.ApiTransaction.TransactionsEndpoint}
  ],
  transaction_req_options: [
    plug: {Req.Test, SumupIntegration.Sales.ApiTransaction.TransactionEndpoint}
  ]
