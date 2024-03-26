defmodule SumupIntegration.Pipeline.DescriptionNormalizer do
  alias SumupIntegration.Sales.SaleTransaction

  # Matches patterns like "1 x Apple juice" and "10 x Apple Juice, 10 x Orange Juice"
  @pattern_group_regex ~r/\s*(?<quantity>\d+)\s*x\s*(?<description>[^,]*),?/i
  # This regex is used to validate whether the whole string matches the pattern
  @pattern_match_regex ~r/^(\s*(?<quantity>\d+)\s*x\s*(?<description>[^,]*),?)+$/i

  @spec run([SaleTransaction.t()]) :: [SaleTransaction.t()]
  def run(transactions) do
    transactions
    |> Enum.flat_map(&normalize/1)
  end

  @spec normalize(SaleTransaction.t()) :: [SaleTransaction.t()]
  defp normalize(%SaleTransaction{description: description} = transaction),
    do: do_normalize(transaction, Regex.match?(@pattern_match_regex, description))

  defp do_normalize(transaction, _normalize? = false), do: [transaction]

  defp do_normalize(%SaleTransaction{quantity: quantity} = transaction, _normalize?)
       when quantity > 1,
       do: [transaction]

  defp do_normalize(
         %SaleTransaction{description: description, amount: amount} = transaction,
         _normalize? = true
       ) do
    case get_groups(description) do
      {:ok, positions} ->
        total_count = positions |> Enum.reduce(0, fn position, agg -> position.quantity + agg end)
        amount_per_position = Float.round(amount / total_count, 2)
        last_position_idx = length(positions) - 1

        {transactions, _amount} =
          positions
          |> Enum.with_index()
          |> Enum.reduce({[], 0}, fn {position, idx}, {agg, running_amount} ->
            position_amount =
              if idx == last_position_idx, do: Float.round(amount - running_amount, 2), else: amount_per_position

            next_transaction = %SaleTransaction{
              transaction
              | quantity: position.quantity,
                description: position.position_name,
                amount: position_amount
            }

            {[next_transaction | agg], running_amount + position_amount}
          end)

        Enum.reverse(transactions)

      {:error, _reason} ->
        [transaction]
    end
  end

  defp get_groups(description) do
    matched_groups = Regex.scan(@pattern_group_regex, description, capture: :all_names)

    correct_groups =
      matched_groups
      |> Enum.reduce([], fn
        [position_name, quantity], agg ->
          case Integer.parse(quantity) do
            {parsed_quantity, _base} ->
              [%{position_name: String.trim(position_name), quantity: parsed_quantity} | agg]

            :error ->
              agg
          end

        _, agg ->
          agg
      end)

    if length(matched_groups) == length(correct_groups) do
      {:ok, Enum.reverse(correct_groups)}
    else
      {:error, :malformed_description}
    end
  end
end
