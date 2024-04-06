defmodule SumupIntegration.Factory do
  alias SumupIntegration.Repo

  def build(:sale_transaction) do
    amount = Faker.Commerce.price()

    %SumupIntegration.Sales.SaleTransaction{
      transaction_id: Faker.UUID.v4(),
      status: Faker.Util.pick([:successful, :failed, :refunded, :pending, :unknown]),
      sold_by: Faker.Internet.email(),
      # give a date from last year
      created_at: Faker.DateTime.backward(365),
      currency: Faker.Currency.code(),
      amount: amount,
      amount_gross: amount,
      tip_amount: Faker.Util.pick([0.0, 1.0, 2.0, 3.0, 4.5]),
      description: Faker.Util.pick(["", Faker.Beer.name()]),
      price_category_name:
        Faker.Util.pick(["Public", "Standard", "Extra", "DJs", "DJ", "Crew", ""]),
      payment_method: Faker.Util.pick([:card, :cash, :unknown]),
      quantity: Faker.random_between(1, 15),
      event_name: nil,
      sale_type: Faker.Util.pick([nil, :public, :crew, :free])
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
