defmodule SumupIntegration.Sales.SalesTest do
  use ExUnit.Case

  import SumupIntegration.Factory

  alias SumupIntegration.Sales
  alias SumupIntegration.Sales.SaleTransaction

  describe "run_pipeline!/1" do
    test "executes all given pipelines in order" do
      input_transactions = [
        build(:sale_transaction),
        build(:sale_transaction),
        build(:sale_transaction)
      ]

      transactions =
        %Sales{transactions: input_transactions}
        |> Sales.run_pipeline!([&pipeline_a/1, &pipeline_b/1, &pipeline_c/1])
        |> Sales.to_transactions()

      assert [
               %SaleTransaction{event_name: "Pipeline A Update!", amount: 12345, quantity: 9999},
               %SaleTransaction{event_name: "Pipeline A Update!", amount: 12345, quantity: 9999},
               %SaleTransaction{event_name: "Pipeline A Update!", amount: 12345, quantity: 9999}
             ] = transactions
    end
  end

  defp pipeline_a(transcations) do
    transcations
    |> Enum.map(&%SaleTransaction{&1 | event_name: "Pipeline A Update!"})
  end

  defp pipeline_b(transcations) do
    transcations
    |> Enum.map(&%SaleTransaction{&1 | amount: 12345})
  end

  defp pipeline_c(transcations) do
    transcations
    |> Enum.map(&%SaleTransaction{&1 | quantity: 9999})
  end
end
