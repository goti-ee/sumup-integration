defmodule SumupIntegration.Pipeline.EventDetectorTest do
  use ExUnit.Case

  import SumupIntegration.Factory

  alias SumupIntegration.Pipeline.EventDetector
  alias SumupIntegration.Sales.SaleTransaction

  setup do
    %{
      events: [
        %{
          name: "Test event 1",
          start_at: DateTime.new!(~D[2021-03-08], ~T[20:00:00], "Etc/UTC"),
          end_at: DateTime.new!(~D[2021-03-09], ~T[09:00:00], "Etc/UTC")
        },
        %{
          name: "Test event 2",
          start_at: DateTime.new!(~D[2021-03-11], ~T[20:00:00], "Etc/UTC"),
          end_at: DateTime.new!(~D[2021-03-12], ~T[09:00:00], "Etc/UTC")
        },
        %{
          name: "Test event 3",
          start_at: DateTime.new!(~D[2022-03-11], ~T[20:00:00], "Etc/UTC"),
          end_at: DateTime.new!(~D[2022-03-12], ~T[09:00:00], "Etc/UTC")
        }
      ]
    }
  end

  describe "run/1" do
    test "overwrites event_name when event is supported", %{events: events} do
      transactionA = build(:sale_transaction)
      transactionB = build(:sale_transaction, created_at: ~U[2022-03-12 03:05:56Z])
      transcationC = build(:sale_transaction)

      assert [
               ^transactionA,
               %SaleTransaction{event_name: "Test event 3"},
               ^transcationC
             ] = EventDetector.run([transactionA, transactionB, transcationC], events)
    end

    test "leaves unmatched transactions as-is and preserves order", %{events: events} do
      transactions = [
        build(:sale_transaction),
        build(:sale_transaction),
        build(:sale_transaction)
      ]

      assert ^transactions = EventDetector.run(transactions, events)
    end

    test "matches time with inclusive filter", %{events: events} do
      transaction = build(:sale_transaction, created_at: ~U[2022-03-12 09:00:00Z])

      assert [%SaleTransaction{event_name: "Test event 3"}] =
               EventDetector.run([transaction], events)
    end
  end
end
