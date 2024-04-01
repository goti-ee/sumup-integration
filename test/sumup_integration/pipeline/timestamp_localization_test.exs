defmodule SumupIntegration.Pipeline.TimestampLocalizationTest do
  use ExUnit.Case

  alias SumupIntegration.Sales.SaleTransaction
  alias SumupIntegration.Pipeline.TimestampLocalization
  import SumupIntegration.Factory

  describe "run/1" do
    test "updates timezone of a transaction to a given one" do
      transaction = build(:sale_transaction, created_at: ~U[2022-03-12 03:05:56Z])

      [%SaleTransaction{created_at_local: actual_timestamp}] =
        TimestampLocalization.run([transaction], "Europe/Madrid")

      assert ~N[2022-03-12 04:05:56] == actual_timestamp
    end
  end

  test "uses Europe/Tallinn by default" do
    transaction = build(:sale_transaction, created_at: ~U[2022-03-12 03:05:56Z])

    [%SaleTransaction{created_at_local: actual_timestamp}] =
      TimestampLocalization.run([transaction])

    assert ~N[2022-03-12 05:05:56] == actual_timestamp
  end
end
