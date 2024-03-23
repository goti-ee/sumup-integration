defmodule SumupIntegration.Pipeline.SuperficialSaleRemoval do
  alias SumupIntegration.Sales.SaleTransaction

  @superficial_price 0.01

  def run(transactions) do
    transactions
    |> Enum.map(&remove_superficial_amount(&1))
  end

  defp remove_superficial_amount(
         %SaleTransaction{quantity: quantity, amount: amount} = transaction
       ) do
    expected_amount = quantity * @superficial_price

    if expected_amount === amount do
      %SaleTransaction{transaction | amount: 0.0}
    else
      transaction
    end
  end
end
