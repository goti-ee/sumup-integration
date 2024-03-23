defmodule SumupIntegration.Pipeline.SaleTypeDetectorTest do
  use ExUnit.Case

  import SumupIntegration.Factory

  alias SumupIntegration.Sales.SaleTransaction
  alias SumupIntegration.Pipeline.SaleTypeDetector

  describe "run/1" do
    test "marks item with cost 0 as free in regards to category name" do
      transaction =
        build(:sale_transaction, amount: 0, price_category_name: "Crew", sale_type: nil)

      assert [%SaleTransaction{sale_type: :free}] = SaleTypeDetector.run([transaction])
    end

    test "marks dj sales as :free" do
      transaction = build(:sale_transaction, price_category_name: "DJ", sale_type: nil)

      assert [%SaleTransaction{sale_type: :free}] = SaleTypeDetector.run([transaction])
    end

    test "marks dj sales as :free ignoring casing" do
      transaction = build(:sale_transaction, price_category_name: "DjS", sale_type: nil)

      assert [%SaleTransaction{sale_type: :free}] = SaleTypeDetector.run([transaction])
    end

    test "marks crew sales as :crew" do
      transaction = build(:sale_transaction, price_category_name: "Crew", sale_type: nil)

      assert [%SaleTransaction{sale_type: :crew}] = SaleTypeDetector.run([transaction])
    end

    test "marks crew sales as :crew ignoring casing" do
      transaction = build(:sale_transaction, price_category_name: "CREWss", sale_type: nil)

      assert [%SaleTransaction{sale_type: :crew}] = SaleTypeDetector.run([transaction])
    end

    test "marks any other item as :public" do
      transactions = [
        build(:sale_transaction, price_category_name: "Public", sale_type: nil),
        build(:sale_transaction, price_category_name: "", sale_type: nil),
        build(:sale_transaction, price_category_name: "crw", sale_type: nil)
      ]

      assert [
               %SaleTransaction{sale_type: :public},
               %SaleTransaction{sale_type: :public},
               %SaleTransaction{sale_type: :public}
             ] = SaleTypeDetector.run(transactions)
    end
  end
end
