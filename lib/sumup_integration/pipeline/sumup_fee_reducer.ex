defmodule SumupIntegration.Pipeline.SumupFeeReducer do
  alias SumupIntegration.Sales.SaleTransaction

  @sumup_fee_in_percentages 1.69

  @spec run([SaleTransaction.t()]) :: [SaleTransaction.t()]
  def run(transactions) do
    transactions
    |> Enum.map(&apply_fee/1)
  end

  defp apply_fee(%SaleTransaction{payment_method: :card} = transaction) do
    amount_gross = transaction.amount_gross

    # 0.9831
    remaining_amount_as_decimal = (100 - @sumup_fee_in_percentages) / 100
    amount = Float.round(amount_gross * remaining_amount_as_decimal, 2) + transaction.tip_amount

    %SaleTransaction{transaction | amount: amount}
  end

  defp apply_fee(_ = transaction), do: transaction
end
