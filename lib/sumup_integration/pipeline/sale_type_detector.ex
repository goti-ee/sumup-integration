defmodule SumupIntegration.Pipeline.SaleTypeDetector do
  alias SumupIntegration.Sales.SaleTransaction

  @description_sale_type_regex ~r/\s+(?<sale_type>crew|dj|djs|standard)(?:\s+|$|,)/i

  def run(transactions) do
    transactions
    |> Enum.map(&detect_sale_type(&1))
  end

  defp detect_sale_type(
         %SaleTransaction{
           price_category_name: price_category_name,
           amount: amount,
           description: description
         } = transaction
       ) do
    price_category_name = String.downcase(price_category_name)

    cond do
      amount == 0 ->
        %SaleTransaction{transaction | sale_type: :free}

      # This is redundant in the majority of cases because the previous clause already matches them
      String.contains?(price_category_name, "dj") ->
        %SaleTransaction{transaction | sale_type: :free}

      String.contains?(price_category_name, "crew") ->
        %SaleTransaction{transaction | sale_type: :crew}

      can_parse_description?(description) ->
        %{"sale_type" => regex_sale_type} =
          Regex.named_captures(@description_sale_type_regex, description)

        sale_type =
          case String.downcase(regex_sale_type) do
            "crew" -> :crew
            "djs" -> :free
            "dj" -> :free
            "standard" -> :public
          end

        description = Regex.replace(@description_sale_type_regex, description, "")

        %SaleTransaction{
          transaction
          | sale_type: sale_type,
            price_category_name: regex_sale_type,
            description: description
        }

      true ->
        %SaleTransaction{transaction | sale_type: :public}
    end
  end

  defp can_parse_description?(description) do
    match? = Regex.match?(@description_sale_type_regex, description)
    groups = Regex.scan(@description_sale_type_regex, description, capture: :all_names)

    match? && length(groups) === 1
  end
end
