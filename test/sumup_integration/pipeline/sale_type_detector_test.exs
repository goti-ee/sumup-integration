defmodule SumupIntegration.Pipeline.SaleTypeDetectorTest do
  use ExUnit.Case

  import SumupIntegration.Factory

  alias SumupIntegration.Sales.SaleTransaction
  alias SumupIntegration.Pipeline.SaleTypeDetector

  describe "run/1" do
    test "marks item with cost 0 as free in regards to category name" do
      transaction =
        build(:sale_transaction,
          amount: 0,
          amount_gross: 0,
          price_category_name: "Crew",
          sale_type: nil
        )

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

    test "marks sales that contain 'Crew' in the position description as :crew" do
      transaction =
        build(:sale_transaction,
          price_category_name: "",
          description: "Orange Juice Crew",
          sale_type: nil
        )

      assert [
               %SaleTransaction{
                 sale_type: :crew,
                 description: "Orange Juice",
                 price_category_name: "Crew"
               }
             ] =
               SaleTypeDetector.run([transaction])
    end

    test "marks sales that contain 'DJs' in the position description as :free" do
      transaction =
        build(:sale_transaction,
          price_category_name: "",
          description: "Orange Juice DJs",
          sale_type: nil
        )

      assert [
               %SaleTransaction{
                 sale_type: :free,
                 description: "Orange Juice",
                 price_category_name: "DJs"
               }
             ] =
               SaleTypeDetector.run([transaction])
    end

    test "does not use special sale_type when actual position name includes matching type substring" do
      transactions = [
        build(:sale_transaction,
          price_category_name: "",
          description: "OraCrewnge Juice ",
          sale_type: nil
        ),
        build(:sale_transaction,
          price_category_name: "",
          description: "OrangDJse Juice ",
          sale_type: nil
        )
      ]

      assert [
               %SaleTransaction{sale_type: :public, description: "OraCrewnge Juice "},
               %SaleTransaction{sale_type: :public, description: "OrangDJse Juice "}
             ] =
               SaleTypeDetector.run(transactions)
    end

    test "does not modify sale_type if there are multiple matching options in description" do
      transaction =
        build(:sale_transaction,
          price_category_name: "",
          description: "1 x Orange Juice DJs, 3 x Apple Juice Crew",
          sale_type: nil
        )

      assert [
               %SaleTransaction{
                 sale_type: :public,
                 description: "1 x Orange Juice DJs, 3 x Apple Juice Crew"
               }
             ] = SaleTypeDetector.run([transaction])
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
