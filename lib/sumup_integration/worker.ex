defmodule SumupIntegration.Worker do
  use Oban.Worker,
    max_attempts: 1,
    unique: [period: :infinity, states: ~w(available executing)a]

  alias SumupIntegration.Sales

  alias SumupIntegration.Pipeline.{
    EventDetector,
    SuperficialSaleRemoval,
    SaleTypeDetector,
    DescriptionNormalizer,
    SumupFeeReducer,
    TimestampLocalization
  }

  require Logger

  @default_sync_type "incremental"

  @impl Oban.Worker
  def perform(%Oban.Job{args: args} = _job) do
    sync_type = Map.get(args, "type", @default_sync_type)

    Sales.new()
    |> Sales.get_offset!(parse_sync_type(sync_type))
    |> Sales.fetch!()
    |> Sales.run_pipeline!([
      &EventDetector.run/1,
      &DescriptionNormalizer.run/1,
      &SuperficialSaleRemoval.run/1,
      &SaleTypeDetector.run/1,
      &SumupFeeReducer.run/1,
      &TimestampLocalization.run/1
    ])
    |> Sales.insert!()

    :ok
  end

  defp parse_sync_type(sync_type) do
    case sync_type do
      "incremental" -> :last
      "last-month" -> :month_ago
      "full" -> :first
      _ -> :last
    end
  end
end
