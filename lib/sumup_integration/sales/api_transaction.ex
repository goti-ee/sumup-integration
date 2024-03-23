defmodule SumupIntegration.Sales.ApiTransaction do
  @type t :: %{
          id: String.t(),
          status: String.t(),
          timestamp: String.t(),
          currency: String.t(),
          total_price: float(),
          # position name
          name: String.t(),
          # price group name
          description: String.t(),
          payment_type: String.t(),
          quantity: integer()
        }

  @spec fetch!(String.t() | nil) :: [t()]
  def fetch!(last_fetched_id) do
    initial_query = if last_fetched_id != nil, do: build_query(last_fetched_id), else: ""

    do_fetch_sales!(initial_query)
    |> Flow.from_enumerable(max_demand: 10)
    |> Flow.filter(fn
      # Let's drop refunded right away. It seems API fails for them
      %{"status" => "REFUNDED"} -> false
      # Failed are not useful
      %{"status" => "FAILED"} -> false
      _ -> true
    end)
    |> Flow.flat_map(fn sale ->
      %{"products" => products} =
        Req.get!(
          "https://api.sumup.com/v0.1/me/transactions",
          params: [id: Map.fetch!(sale, "id")],
          auth: {:bearer, api_key()}
        ).body

      products
      |> Enum.map(fn product ->
        Map.merge(sale, %{
          "name" => Map.get(product, "name", ""),
          "total_price" => Map.fetch!(product, "total_price"),
          "quantity" => Map.get(product, "quantity", 0),
          "description" => Map.get(product, "description", "")
        })
      end)
    end)
    |> Enum.to_list()
  end

  defp do_fetch_sales!(query, agg \\ []) do
    %{"items" => items} =
      resp =
      Req.get!(
        "https://api.sumup.com/v0.1/me/transactions/history#{if query !== "", do: "?" <> query, else: query}",
        auth: {:bearer, api_key()}
      ).body

    next_items = agg ++ items

    links = Map.get(resp, "links", [])

    case Enum.find(links, nil, &match_next_link/1) do
      %{"href" => next_query, "rel" => "next"} -> do_fetch_sales!(next_query, next_items)
      _ -> next_items
    end
  end

  @spec to_sale_transaction!(t()) :: map()
  def to_sale_transaction!(opts) do
    {:ok, created_at, _offset} = DateTime.from_iso8601(Map.fetch!(opts, "timestamp"))

    %{
      transaction_id: Map.fetch!(opts, "id"),
      status: Map.fetch!(opts, "status") |> parse_status(),
      sold_by: Map.fetch!(opts, "user"),
      created_at: created_at,
      currency: Map.fetch!(opts, "currency"),
      amount: Map.fetch!(opts, "total_price"),
      description: Map.get(opts, "name", "") |> String.trim(),
      payment_method: Map.fetch!(opts, "payment_type") |> parse_payment_method(),
      quantity: Map.get(opts, "quantity", 0),
      price_category_name: Map.get(opts, "description", "")
    }
  end

  defp build_query(transaction_id),
    do: "limit=10&oldest_ref=#{transaction_id}&order=ascending&skip_tx_result=true"

  defp match_next_link(%{"rel" => "next"}), do: true
  defp match_next_link(_), do: false

  defp parse_status("SUCCESSFUL"), do: :successful
  defp parse_status("FAILED"), do: :failed
  defp parse_status("REFUNDED"), do: :refunded
  defp parse_status("PENDING"), do: :pending
  defp parse_status(_), do: :unknown

  defp parse_payment_method("CASH"), do: :cash
  defp parse_payment_method("POS"), do: :card
  defp parse_payment_method("ECOM"), do: :card
  defp parse_payment_method(_), do: :unknown

  defp api_key do
    Application.fetch_env!(:sumup_integration, :sumup_api_key)
  end
end
