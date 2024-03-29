defmodule SumupIntegration.Pipeline.EventDetector do
  alias SumupIntegration.Sales.SaleTransaction
  alias SumupIntegration.Event

  @type event :: %{name: String.t(), start_at: DateTime.t(), end_at: DateTime.t()}

  @spec run([SaleTransaction.t()]) :: [SaleTransaction.t()]
  @spec run([SaleTransaction.t()], [event()]) :: [SaleTransaction.t()]
  def run(transactions) do
    events = get_events()

    run(transactions, events)
  end

  def run(transactions, events) do
    transactions
    |> Enum.map(fn %SaleTransaction{created_at: created_at} = transaction ->
      case match_event(created_at, events) do
        {:ok, %{name: name}} -> %SaleTransaction{transaction | event_name: name}
        {:error, _reason} -> transaction
      end
    end)
  end

  @spec match_event(DateTime.t(), [event()]) :: {:ok, event()} | {:error, :not_found}
  def match_event(timestamp, events) do
    match =
      events
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

  @spec get_events() :: [Event.t()]
  def get_events() do
    Event.get_all()
  end
end
