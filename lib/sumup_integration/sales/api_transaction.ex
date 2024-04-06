defmodule SumupIntegration.Sales.ApiTransaction do
  @type t :: %{
          id: String.t(),
          status: String.t(),
          timestamp: String.t(),
          currency: String.t(),
          total_price: float(),
          tip_amount: float(),
          # position name
          name: String.t(),
          # price group name
          description: String.t(),
          payment_type: String.t(),
          quantity: integer()
        }

  @spec fetch!(String.t() | nil) :: [t()]
  def fetch!(last_fetched_id) do
    parallel? = Keyword.get(config(), :parallel?, true)
    initial_query = if last_fetched_id != nil, do: build_query(last_fetched_id), else: ""

    fetch_base_transactions!(initial_query)
    |> process_transactions(parallel?)
  end

  defp build_query(transaction_id),
    do: "limit=10&oldest_ref=#{transaction_id}&order=ascending&skip_tx_result=true"

  defp fetch_base_transactions!(query, agg \\ []) do
    %{"items" => items} = resp = get_sumup_transactions(query)

    next_items = agg ++ items

    links = Map.get(resp, "links", [])

    case Enum.find(links, nil, &match_next_link/1) do
      %{"href" => next_query, "rel" => "next"} -> fetch_base_transactions!(next_query, next_items)
      _ -> next_items
    end
  end

  defp get_sumup_transactions(query) do
    transactions_req_options = Keyword.get(config(), :transactions_req_options, [])

    response =
      [
        base_url:
          "https://api.sumup.com/v0.1/me/transactions/history#{if query !== "", do: "?" <> query, else: query}"
      ]
      |> Keyword.merge(transactions_req_options)
      |> Req.request!()

    response.body
  end

  defp match_next_link(%{"rel" => "next"}), do: true
  defp match_next_link(_), do: false

  defp process_transactions(transactions, _parallel? = true) do
    transactions
    |> Flow.from_enumerable(max_demand: 10)
    |> Flow.filter(&filter_by_status/1)
    |> Flow.flat_map(&enrich_with_details/1)
    |> Enum.to_list()
  end

  defp process_transactions(transactions, _parallel? = false) do
    transactions
    |> Enum.filter(&filter_by_status/1)
    |> Enum.flat_map(&enrich_with_details/1)
  end

  # Let's drop refunded right away. It seems API details fails for them
  defp filter_by_status(%{"status" => "REFUNDED"}), do: false
  # Failed are not useful
  defp filter_by_status(%{"status" => "FAILED"}), do: false
  defp filter_by_status(_), do: true

  defp enrich_with_details(sale) do
    %{"products" => products, "tip_amount" => tip_amount} =
      get_sumup_transaction(Map.fetch!(sale, "id"))

    products
    |> Enum.with_index()
    |> Enum.map(fn {product, idx} ->
      product_tip_amount = if idx == 0, do: tip_amount, else: 0.0

      Map.merge(sale, %{
        "name" => Map.get(product, "name", ""),
        "total_price" => Map.fetch!(product, "total_price"),
        "quantity" => Map.get(product, "quantity", 0),
        "description" => Map.get(product, "description", ""),
        # Assign tip only to the first transcation of the group
        "tip_amount" => product_tip_amount
      })
    end)
  end

  defp get_sumup_transaction(id) do
    transaction_req_options = Keyword.get(config(), :transaction_req_options, [])

    response =
      [
        base_url: "https://api.sumup.com/v0.1/me/transactions",
        params: [id: id]
      ]
      |> Keyword.merge(transaction_req_options)
      |> Req.request!()

    response.body
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
      amount: Map.fetch!(opts, "total_price") + Map.fetch!(opts, "tip_amount"),
      amount_gross: Map.fetch!(opts, "total_price"),
      tip_amount: Map.fetch!(opts, "tip_amount"),
      description: Map.get(opts, "name", "") |> String.trim(),
      payment_method: Map.fetch!(opts, "payment_type") |> parse_payment_method(),
      quantity: Map.get(opts, "quantity", 0),
      price_category_name: Map.get(opts, "description", "")
    }
  end

  defp parse_status("SUCCESSFUL"), do: :successful
  defp parse_status("FAILED"), do: :failed
  defp parse_status("REFUNDED"), do: :refunded
  defp parse_status("PENDING"), do: :pending
  defp parse_status(_), do: :unknown

  defp parse_payment_method("CASH"), do: :cash
  defp parse_payment_method("POS"), do: :card
  defp parse_payment_method("ECOM"), do: :card
  defp parse_payment_method(_), do: :unknown

  defp config(), do: Application.get_env(:sumup_integration, __MODULE__, [])
end
