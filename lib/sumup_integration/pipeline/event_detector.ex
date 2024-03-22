defmodule SumupIntegration.Pipeline.EventDetector do
  alias SumupIntegration.Sales.SaleTransaction

  @type event :: %{name: String.t(), start_at: DateTime.t(), end_at: DateTime.t()}

  def run(transactions) do
    transactions
    |> Enum.map(fn %SaleTransaction{created_at: created_at} = transaction ->
      case match_event(created_at) do
        {:ok, %{name: name}} -> %SaleTransaction{transaction | event_name: name}
        {:error, _reason} -> transaction
      end
    end)
  end

  @spec match_event(DateTime.t()) :: {:ok, event()} | {:error, :not_found}
  def match_event(timestamp) do
    match =
      get_events()
      |> Enum.find(nil, fn %{start_at: start_at, end_at: end_at} ->
        after_start = DateTime.compare(start_at, timestamp) != :gt
        before_end = DateTime.compare(timestamp, end_at) != :gt

        after_start && before_end
      end)

    case match do
      nil -> {:error, :not_found}
      event -> {:ok, event}
    end
  end

  @spec get_events() :: [event()]
  def get_events() do
    [
      %{
        name: "Girls Rule the World vol.3 (08.03.24)",
        start_at: DateTime.new!(~D[2024-03-08], ~T[20:00:00], "Etc/UTC"),
        end_at: DateTime.new!(~D[2024-03-09], ~T[09:00:00], "Etc/UTC")
      }
    ]
  end
end
