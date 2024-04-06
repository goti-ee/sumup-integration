defmodule SumupIntegration.Pipeline.SumupFeeReducerTest do
  use ExUnit.Case

  import SumupIntegration.Factory

  alias SumupIntegration.Sales.SaleTransaction
  alias SumupIntegration.Pipeline.SumupFeeReducer

  describe "run/1" do
    test "deducts sumup fee from the amount" do
      transactions = [
        build(:sale_transaction,
          payment_method: :card,
          amount: 5.0,
          amount_gross: 5.0,
          tip_amount: 0.0
        ),
        build(:sale_transaction,
          payment_method: :card,
          amount: 12.589,
          amount_gross: 12.589,
          tip_amount: 0.0
        ),
        build(:sale_transaction,
          payment_method: :card,
          amount: 3.0,
          amount_gross: 3.0,
          tip_amount: 0.0
        )
      ]

      assert [
               %SaleTransaction{amount: 4.92, amount_gross: 5.0},
               %SaleTransaction{amount: 12.38, amount_gross: 12.589},
               %SaleTransaction{amount: 2.95, amount_gross: 3.0}
             ] = SumupFeeReducer.run(transactions)
    end

    test "adds tip amount to the final amount" do
      transactions = [
        build(:sale_transaction,
          payment_method: :card,
          amount: 5.0,
          amount_gross: 5.0,
          tip_amount: 2.0
        ),
        build(:sale_transaction,
          payment_method: :card,
          amount: 3.0,
          amount_gross: 3.0,
          tip_amount: 0.0
        )
      ]

      assert [
               %SaleTransaction{amount: 6.92, amount_gross: 5.0, tip_amount: 2.0},
               %SaleTransaction{amount: 2.95, amount_gross: 3.0, tip_amount: +0.0}
             ] = SumupFeeReducer.run(transactions)
    end

    test "ignores non-cash transactions" do
      transaction =
        build(:sale_transaction, payment_method: :cash, amount: 5.0, amount_gross: 5.0)

      assert [
               %SaleTransaction{amount: 5.0, amount_gross: 5.0}
             ] = SumupFeeReducer.run([transaction])
    end
  end
end
