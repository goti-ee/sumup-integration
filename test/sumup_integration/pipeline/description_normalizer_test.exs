defmodule SumupIntegration.Pipeline.DescriptionNormalizerTest do
  use ExUnit.Case

  import SumupIntegration.Factory

  alias SumupIntegration.Sales.SaleTransaction
  alias SumupIntegration.Pipeline.DescriptionNormalizer

  describe "run/1" do
    test "normalizes transaction description and quantity" do
      transactions = [
        build(:sale_transaction, quantity: 1, description: "1 x Apple juice"),
        build(:sale_transaction, quantity: 1, description: "5 x Apple juice"),
        build(:sale_transaction,
          quantity: 1,
          description: "6 x Apple juice, 10 x Orange juice 0.5l"
        )
      ]

      assert [
               %SaleTransaction{quantity: 1, description: "Apple juice"},
               %SaleTransaction{quantity: 5, description: "Apple juice"},
               %SaleTransaction{quantity: 6, description: "Apple juice"},
               %SaleTransaction{quantity: 10, description: "Orange juice 0.5l"}
             ] = DescriptionNormalizer.run(transactions)
    end

    test "splits amount between multiple positions in a transaction" do
      transactions = [
        build(:sale_transaction,
          amount: 10.0,
          amount_gross: 10.0,
          quantity: 1,
          description: "3 x Apple juice, 2 x Orange Juice"
        )
      ]

      assert [
               %SaleTransaction{
                 amount: 2.0,
                 amount_gross: 2.0,
                 quantity: 3,
                 description: "Apple juice"
               },
               %SaleTransaction{
                 amount: 8.0,
                 amount_gross: 8.0,
                 quantity: 2,
                 description: "Orange Juice"
               }
             ] = DescriptionNormalizer.run(transactions)
    end

    test "rounds to 2 numbers after , for ugly number" do
      transactions = [
        build(:sale_transaction,
          amount: 10.0,
          amount_gross: 10.0,
          quantity: 1,
          description: "5 x Apple juice, 2 x Orange Juice"
        )
      ]

      assert [
               %SaleTransaction{
                 amount: 1.43,
                 amount_gross: 1.43,
                 quantity: 5,
                 description: "Apple juice"
               },
               %SaleTransaction{
                 amount: 8.57,
                 amount_gross: 8.57,
                 quantity: 2,
                 description: "Orange Juice"
               }
             ] = DescriptionNormalizer.run(transactions)
    end

    test "trims transaction description" do
      transactions = [
        build(:sale_transaction, quantity: 1, description: "1 x   Apple juice     "),
        build(:sale_transaction,
          quantity: 1,
          description: "6 x   Apple juice, 10 x   Orange juice 0.5l   "
        )
      ]

      assert [
               %SaleTransaction{quantity: 1, description: "Apple juice"},
               %SaleTransaction{quantity: 6, description: "Apple juice"},
               %SaleTransaction{quantity: 10, description: "Orange juice 0.5l"}
             ] = DescriptionNormalizer.run(transactions)
    end

    test "ignores description that doesn't need normalization" do
      transaction = build(:sale_transaction, quantity: 1, description: "Apxxxple juice")

      assert [
               %SaleTransaction{quantity: 1, description: "Apxxxple juice"}
             ] = DescriptionNormalizer.run([transaction])
    end

    test "ignores transaction that was adjusted" do
      transaction = build(:sale_transaction, quantity: 3, description: "1 x Apple juice")

      assert [
               %SaleTransaction{quantity: 3, description: "1 x Apple juice"}
             ] = DescriptionNormalizer.run([transaction])
    end

    test "ignores transaction with delimeter in the name" do
      transactions = [
        build(:sale_transaction, quantity: 1, description: "1 x App,,,,le jMatchuice"),
        build(:sale_transaction,
          quantity: 1,
          description: "1 x App,,,,le jMatchuice, 2 x Orange Juice"
        )
      ]

      assert [
               %SaleTransaction{quantity: 1, description: "1 x App,,,,le jMatchuice"},
               %SaleTransaction{
                 quantity: 1,
                 description: "1 x App,,,,le jMatchuice, 2 x Orange Juice"
               }
             ] = DescriptionNormalizer.run(transactions)
    end
  end
end
