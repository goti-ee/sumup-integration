defmodule SumupIntegration.Pipeline.TimestampLocalization do
  alias SumupIntegration.Sales.SaleTransaction

  @spec run([SaleTransaction.t()]) :: [SaleTransaction.t()]
  def run(transactions, time_zone \\ nil) do
    time_zone = if time_zone != nil, do: time_zone, else: config()[:time_zone]

    transactions
    |> Enum.map(&localize_timestamp(&1, time_zone))
  end

  @spec localize_timestamp(SaleTransaction.t(), Calendar.time_zone()) :: SaleTransaction.t()
  defp localize_timestamp(%SaleTransaction{created_at: created_at} = transaction, time_zone) do
    shifted_created_at = DateTime.shift_zone!(created_at, time_zone)

    %SaleTransaction{transaction | created_at_local: DateTime.to_naive(shifted_created_at)}
  end

  defp config(), do: Application.get_env(:sumup_integration, __MODULE__, [])
end
