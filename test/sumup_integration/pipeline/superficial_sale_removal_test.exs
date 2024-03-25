defmodule SumupIntegration.Pipeline.SuperficialSaleRemovalTest do
  use ExUnit.Case

  import SumupIntegration.Factory

  alias SumupIntegration.Pipeline.SuperficialSaleRemoval
  alias SumupIntegration.Sales.SaleTransaction

  describe "run/1" do
    test "overwrites amount when it's superificial" do
      transactionA = build(:sale_transaction)
      transactionB = build(:sale_transaction, amount: 0.03, quantity: 3)
      transcationC = build(:sale_transaction, amount: 0.01, quantity: 1)

      assert [
               ^transactionA,
               %SaleTransaction{amount: +0.0, quantity: 3},
               %SaleTransaction{amount: +0.0, quantity: 1}
             ] = SuperficialSaleRemoval.run([transactionA, transactionB, transcationC])
    end

    test "leaves unmatched transactions as-is and preserves order" do
      transactions = [
        build(:sale_transaction),
        build(:sale_transaction),
        build(:sale_transaction)
      ]

      assert ^transactions = SuperficialSaleRemoval.run(transactions)
    end
  end
end
