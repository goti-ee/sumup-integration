alias SumupIntegration.Sales
alias SumupIntegration.Sales.SaleTransaction

run_sales = fn () ->
  Sales.new()
  |> Sales.get_last_offset!()
  |> Sales.fetch!()
  |> Sales.run_pipeline!()
  |> Sales.insert!()
end

insert_events = fn (events) ->
  events
  |> Enum.map(fn event ->
    {:ok, start_at, _offset} = Map.fetch!(event, "start_at") |> DateTime.from_iso8601()
    {:ok, end_at, _offset} = Map.fetch!(event, "end_at") |> DateTime.from_iso8601()

    %{
      name: Map.fetch!(event, "name"),
      start_at: start_at,
      end_at: end_at,
    }
  end)
  |> then(&(SumupIntegration.Repo.insert_all(SumupIntegration.Event, &1)))
end

trigger_tick = fn () ->
  %{}
  |> SumupIntegration.Worker.new()
  |> Oban.insert()
end

remove_all = fn () ->
  SumupIntegration.Sales.SaleTransaction
  |> SumupIntegration.Repo.delete_all()
end
