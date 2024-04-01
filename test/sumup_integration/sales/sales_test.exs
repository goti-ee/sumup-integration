defmodule SumupIntegration.Sales.SalesTest do
  use SumupIntegration.RepoCase

  import SumupIntegration.Factory
  import Ecto.Query

  alias SumupIntegration.Sales
  alias SumupIntegration.Sales.SaleTransaction

  @transactions_fixture_path Path.expand(
                               "../../support/fixtures/transactions_simple.json",
                               __DIR__
                             )
  @transactions_fixture_page_a_path Path.expand(
                                      "../../support/fixtures/transactions_page_a.json",
                                      __DIR__
                                    )
  @transactions_fixture_page_b_path Path.expand(
                                      "../../support/fixtures/transactions_page_b.json",
                                      __DIR__
                                    )
  @transaction_details_path Path.expand(
                              "../../support/fixtures/transactions_details.json",
                              __DIR__
                            )

  describe "Full pipeline" do
    test "fetches all transactions, applies default transformations and inserts into DB" do
      Req.Test.stub(SumupIntegration.Sales.ApiTransaction.TransactionsEndpoint, fn conn ->
        Req.Test.json(conn, transactions_fixture())
      end)

      Req.Test.stub(SumupIntegration.Sales.ApiTransaction.TransactionEndpoint, fn conn ->
        %Plug.Conn{params: %{"id" => transaction_id}} =
          conn
          |> Plug.Conn.fetch_query_params()

        Req.Test.json(conn, transaction_details_fixture(transaction_id))
      end)

      Sales.new()
      |> Sales.fetch!()
      |> Sales.run_pipeline!()
      |> Sales.insert!()

      transactions = Repo.all(from(SaleTransaction))

      assert [
               %SaleTransaction{
                 transaction_id: "25023842-9acd-422d-9285-e540641fa2e6",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:34:53Z],
                 created_at_local: ~N[2022-03-17 00:34:53],
                 currency: "EUR",
                 amount: 8.85,
                 amount_gross: 9.0,
                 description: "Apple shot",
                 payment_method: :card,
                 quantity: 2,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: :public
               },
               %SaleTransaction{
                 transaction_id: "016ec417-1fba-4b08-98bc-b1451895d52c",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:40:33Z],
                 created_at_local: ~N[2022-03-17 00:40:33],
                 currency: "EUR",
                 amount: 1.72,
                 amount_gross: 1.75,
                 description: "IMAGINARY JUICE 0.5l",
                 payment_method: :card,
                 quantity: 1,
                 price_category_name: "Crew ",
                 event_name: nil,
                 sale_type: :crew
               },
               %SaleTransaction{
                 transaction_id: "a64de647-4210-42a1-afc3-5df3fe298589",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:51:00Z],
                 created_at_local: ~N[2022-03-17 00:51:00],
                 currency: "EUR",
                 amount: 5.9,
                 amount_gross: 6.0,
                 description: "Apple shot",
                 payment_method: :card,
                 quantity: 2,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: :public
               },
               %SaleTransaction{
                 transaction_id: "18d9a3f6-5261-4e2e-997b-fe4851cf7b2b",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:56:33Z],
                 created_at_local: ~N[2022-03-17 00:56:33],
                 currency: "EUR",
                 amount: 9.0,
                 amount_gross: 9.0,
                 description: "Сarrot juice",
                 payment_method: :cash,
                 quantity: 1,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: :public
               },
               %SaleTransaction{
                 transaction_id: "18d9a3f6-5261-4e2e-997b-fe4851cf7b2b",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:56:33Z],
                 created_at_local: ~N[2022-03-17 00:56:33],
                 currency: "EUR",
                 amount: 9.0,
                 amount_gross: 9.0,
                 description: "Apple shot",
                 payment_method: :cash,
                 quantity: 3,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: :public
               },
               %SaleTransaction{
                 transaction_id: "bf5f3a1f-38c2-4902-ac23-60d6c151286e",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 23:01:33Z],
                 created_at_local: ~N[2022-03-17 01:01:33],
                 currency: "EUR",
                 amount: +0.0,
                 amount_gross: +0.0,
                 description: "Orange juice",
                 payment_method: :cash,
                 quantity: 1,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: :free
               },
               %SaleTransaction{
                 transaction_id: "19c8d676-f8e8-4f4d-87ef-bb129f0d51d2",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 23:03:33Z],
                 created_at_local: ~N[2022-03-17 01:03:33],
                 currency: "EUR",
                 amount: 0.5,
                 amount_gross: +0.5,
                 description: "Tomato juice",
                 payment_method: :cash,
                 quantity: 1,
                 price_category_name: "DJ",
                 event_name: nil,
                 sale_type: :free
               },
               %SaleTransaction{
                 transaction_id: "19c8d676-f8e8-4f4d-87ef-bb129f0d51d2",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 23:03:33Z],
                 created_at_local: ~N[2022-03-17 01:03:33],
                 currency: "EUR",
                 amount: 2.5,
                 amount_gross: +2.5,
                 description: "Orange peeps",
                 payment_method: :cash,
                 quantity: 5,
                 price_category_name: "Crew",
                 event_name: nil,
                 sale_type: :crew
               }
             ] = transactions
    end
  end

  describe "get_offset/2" do
    setup do
      sales = Sales.new()

      transactions = [
        insert!(:sale_transaction, created_at: ~U[2022-03-12 03:05:56Z]),
        insert!(:sale_transaction, created_at: ~U[2022-04-13 23:11:56Z]),
        insert!(:sale_transaction, created_at: ~U[2022-05-15 16:12:56Z])
      ]

      %{transactions: transactions, sales: sales}
    end

    test "stores last fetched transaction id when relative_timestamp=:last", %{
      transactions: transactions,
      sales: sales
    } do
      %SaleTransaction{transaction_id: expected_transaction_id} = List.last(transactions)

      assert %Sales{last_fetched_id: ^expected_transaction_id} = Sales.get_offset!(sales, :last)
    end

    test "stores nil as transaction id when relative_timestamp=:first", %{sales: sales} do
      assert %Sales{last_fetched_id: nil} = Sales.get_offset!(sales, :first)
    end

    test "stores transaction id that happened at least month ago when relative_timestamp=:month_ago",
         %{transactions: transactions, sales: sales} do
      %SaleTransaction{transaction_id: expected_transaction_id} = List.last(transactions)

      assert %Sales{last_fetched_id: ^expected_transaction_id} =
               Sales.get_offset!(sales, :month_ago)
    end
  end

  describe "fetch!/1" do
    setup do
      sales = Sales.new()

      %{sales: sales}
    end

    test "fetches all transaction by default and decodes them", %{sales: sales} do
      Req.Test.stub(SumupIntegration.Sales.ApiTransaction.TransactionsEndpoint, fn conn ->
        Req.Test.json(conn, transactions_fixture())
      end)

      Req.Test.stub(SumupIntegration.Sales.ApiTransaction.TransactionEndpoint, fn conn ->
        %Plug.Conn{params: %{"id" => transaction_id}} =
          conn
          |> Plug.Conn.fetch_query_params()

        Req.Test.json(conn, transaction_details_fixture(transaction_id))
      end)

      transactions = Sales.fetch!(sales) |> Sales.to_transactions()

      assert [
               %SaleTransaction{
                 transaction_id: "25023842-9acd-422d-9285-e540641fa2e6",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:34:53Z],
                 created_at_local: nil,
                 currency: "EUR",
                 amount: 9.0,
                 amount_gross: 9.0,
                 description: "Apple shot",
                 payment_method: :card,
                 quantity: 2,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: nil
               },
               %SaleTransaction{
                 transaction_id: "016ec417-1fba-4b08-98bc-b1451895d52c",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:40:33Z],
                 created_at_local: nil,
                 currency: "EUR",
                 amount: 1.75,
                 amount_gross: 1.75,
                 description: "IMAGINARY JUICE 0.5l",
                 payment_method: :card,
                 quantity: 1,
                 price_category_name: "Crew ",
                 event_name: nil,
                 sale_type: nil
               },
               %SaleTransaction{
                 transaction_id: "a64de647-4210-42a1-afc3-5df3fe298589",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:51:00Z],
                 created_at_local: nil,
                 currency: "EUR",
                 amount: 6.0,
                 amount_gross: 6.0,
                 description: "2 x Apple shot",
                 payment_method: :card,
                 quantity: 1,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: nil
               },
               %SaleTransaction{
                 transaction_id: "18d9a3f6-5261-4e2e-997b-fe4851cf7b2b",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:56:33Z],
                 created_at_local: nil,
                 currency: "EUR",
                 amount: 9.0,
                 amount_gross: 9.0,
                 description: "Сarrot juice",
                 payment_method: :cash,
                 quantity: 1,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: nil
               },
               %SaleTransaction{
                 transaction_id: "18d9a3f6-5261-4e2e-997b-fe4851cf7b2b",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 22:56:33Z],
                 created_at_local: nil,
                 currency: "EUR",
                 amount: 9.0,
                 amount_gross: 9.0,
                 description: "Apple shot",
                 payment_method: :cash,
                 quantity: 3,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: nil
               },
               %SaleTransaction{
                 transaction_id: "bf5f3a1f-38c2-4902-ac23-60d6c151286e",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 23:01:33Z],
                 created_at_local: nil,
                 currency: "EUR",
                 amount: 0.01,
                 amount_gross: 0.01,
                 description: "Orange juice",
                 payment_method: :cash,
                 quantity: 1,
                 price_category_name: "Public ",
                 event_name: nil,
                 sale_type: nil
               },
               %SaleTransaction{
                 transaction_id: "19c8d676-f8e8-4f4d-87ef-bb129f0d51d2",
                 status: :successful,
                 sold_by: "john.doe@goti.test.ee",
                 created_at: ~U[2022-03-16 23:03:33Z],
                 created_at_local: nil,
                 currency: "EUR",
                 amount: 3.0,
                 amount_gross: 3.0,
                 description: "1 x Tomato juice DJ, 5 x Orange peeps Crew",
                 payment_method: :cash,
                 quantity: 1,
                 price_category_name: "",
                 event_name: nil,
                 sale_type: nil
               }
             ] = transactions
    end

    test "uses last_fetched_id to skip already fetched transactions", %{sales: sales} do
      last_fetched_id = "a64de647-4210-42a1-afc3-5df3fe298589"
      sales = %Sales{sales | last_fetched_id: last_fetched_id}

      Req.Test.stub(SumupIntegration.Sales.ApiTransaction.TransactionsEndpoint, fn conn ->
        %Plug.Conn{params: %{"oldest_ref" => ^last_fetched_id}} =
          conn
          |> Plug.Conn.fetch_query_params()

        Req.Test.json(conn, %{"items" => []})
      end)

      assert [] = Sales.fetch!(sales) |> Sales.to_transactions()
    end

    test "uses pagination if present", %{sales: sales} do
      %{"transactionsA" => transactionsA, "transactionsB" => transactionsB} =
        paginated_transactions_fixture()

      lastPageAId =
        transactionsA
        |> Map.get("items")
        |> List.last()
        |> Map.get("id")

      Req.Test.stub(SumupIntegration.Sales.ApiTransaction.TransactionsEndpoint, fn conn ->
        %Plug.Conn{params: params} =
          conn
          |> Plug.Conn.fetch_query_params()

        result_fixture =
          case params do
            %{"oldest_ref" => ^lastPageAId} -> transactionsB
            _ -> transactionsA
          end

        Req.Test.json(conn, result_fixture)
      end)

      Req.Test.stub(SumupIntegration.Sales.ApiTransaction.TransactionEndpoint, fn conn ->
        %Plug.Conn{params: %{"id" => transaction_id}} =
          conn
          |> Plug.Conn.fetch_query_params()

        Req.Test.json(conn, transaction_details_fixture(transaction_id))
      end)

      transactions = Sales.fetch!(sales) |> Sales.to_transactions()

      assert [
               %SaleTransaction{
                 transaction_id: "25023842-9acd-422d-9285-e540641fa2e6"
               },
               %SaleTransaction{
                 transaction_id: "016ec417-1fba-4b08-98bc-b1451895d52c"
               },
               %SaleTransaction{
                 transaction_id: "a64de647-4210-42a1-afc3-5df3fe298589"
               },
               %SaleTransaction{
                 transaction_id: "18d9a3f6-5261-4e2e-997b-fe4851cf7b2b"
               },
               %SaleTransaction{
                 transaction_id: "18d9a3f6-5261-4e2e-997b-fe4851cf7b2b"
               }
             ] = transactions
    end
  end

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

  defp transactions_fixture() do
    @transactions_fixture_path
    |> File.read!()
    |> Jason.decode!()
  end

  defp paginated_transactions_fixture() do
    %{
      "transactionsA" =>
        @transactions_fixture_page_a_path
        |> File.read!()
        |> Jason.decode!(),
      "transactionsB" =>
        @transactions_fixture_page_b_path
        |> File.read!()
        |> Jason.decode!()
    }
  end

  defp transaction_details_fixture(id) do
    details =
      @transaction_details_path
      |> File.read!()
      |> Jason.decode!()

    Map.fetch!(details, id)
  end
end
