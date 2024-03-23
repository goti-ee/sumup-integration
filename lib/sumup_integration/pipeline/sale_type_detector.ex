defmodule SumupIntegration.Pipeline.SaleTypeDetector do
  alias SumupIntegration.Sales.SaleTransaction

  def run(transactions) do
    transactions
    |> Enum.map(&detect_sale_type(&1))
  end

  defp detect_sale_type(
         %SaleTransaction{price_category_name: price_category_name, amount: amount} = transaction
       ) do
    price_category_name = String.downcase(price_category_name)

    sale_type =
      cond do
        amount == 0 -> :free
        # This is redundant in the majority of cases because the previous clause already matches them
        String.contains?(price_category_name, "dj") -> :free
        String.contains?(price_category_name, "crew") -> :crew
        true -> :public
      end

    %SaleTransaction{transaction | sale_type: sale_type}
  end
end
