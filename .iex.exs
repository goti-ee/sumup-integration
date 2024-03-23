alias SumupIntegration.Sales
alias SumupIntegration.Sales.SaleTransaction

run_sales = fn () ->
  Sales.new()
  |> Sales.get_last_offset!()
  |> Sales.fetch!()
  |> Sales.run_pipeline!()
  |> Sales.insert!()
end
