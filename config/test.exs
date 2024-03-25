import Config

config :sumup_integration, SumupIntegration.Repo,
  username: "postgres",
  password: "postgres",
  database: "sumup_integration_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :sumup_integration, SumupIntegration.Sales.ApiTransaction,
  parallel?: false,
  transactions_req_options: [
    plug: {Req.Test, SumupIntegration.Sales.ApiTransaction.TransactionsEndpoint}
  ],
  transaction_req_options: [
    plug: {Req.Test, SumupIntegration.Sales.ApiTransaction.TransactionEndpoint}
  ]
