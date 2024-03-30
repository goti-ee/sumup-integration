defmodule SumupIntegration.Help do
  @moduledoc """
  A collection of utility functions that are meant to be used inside REPL
  """

  alias SumupIntegration.Sales

  defmacro __using__(_opts) do
    quote do
      alias SumupIntegration.Sales
      alias SumupIntegration.Sales.SaleTransaction

      import SumupIntegration.Help
    end
  end

  def run_sales do
    Sales.new()
    |> Sales.get_last_offset!()
    |> Sales.fetch!()
    |> Sales.run_pipeline!()
    |> Sales.insert!()
  end

  def insert_events(events) do
    events
    |> Enum.map(fn event ->
      {:ok, start_at, _offset} = Map.fetch!(event, "start_at") |> DateTime.from_iso8601()
      {:ok, end_at, _offset} = Map.fetch!(event, "end_at") |> DateTime.from_iso8601()

      %{
        name: Map.fetch!(event, "name"),
        start_at: start_at,
        end_at: end_at
      }
    end)
    |> then(&SumupIntegration.Repo.insert_all(SumupIntegration.Event, &1))
  end

  def trigger_tick do
    %{}
    |> SumupIntegration.Worker.new()
    |> Oban.insert()
  end

  def remove_all do
    SumupIntegration.Sales.SaleTransaction
    |> SumupIntegration.Repo.delete_all()
  end
end
