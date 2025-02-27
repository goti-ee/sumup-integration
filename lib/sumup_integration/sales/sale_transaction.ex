defmodule SumupIntegration.Sales.SaleTransaction do
  use Ecto.Schema

  alias SumupIntegration.Repo

  import Ecto.Query
  import Ecto.Changeset

  @type transaction_status :: :successful | :failed | :refunded | :pending | :unknown
  @type payment_method :: :card | :cash | :unknown
  @type sale_type :: :public | :crew | :free | :member

  @type t :: %__MODULE__{
          transaction_id: String.t(),
          status: transaction_status(),
          sold_by: String.t(),
          created_at: DateTime.t(),
          currency: String.t(),
          amount: float(),
          amount_gross: float(),
          description: String.t(),
          payment_method: payment_method(),
          quantity: pos_integer(),
          price_category_name: String.t(),
          event_name: String.t() | nil,
          sale_type: sale_type() | nil
        }

  schema "sale_transactions" do
    field(:transaction_id, :string)
    field(:status, Ecto.Enum, values: [:successful, :failed, :refunded, :pending, :unknown])
    field(:sold_by, :string)
    field(:created_at, :utc_datetime)

    # Metabase has very limited functionality regarding timezone conversion. As a result, we need to store
    # time in the same timezone that we want to display it in.
    field(:created_at_local, :naive_datetime)
    field(:currency, :string)
    field(:amount, :float)
    field(:amount_gross, :float)
    field(:tip_amount, :float)
    field(:description, :string, default: "")
    field(:payment_method, Ecto.Enum, values: [:card, :cash, :unknown])
    field(:quantity, :integer)
    field(:price_category_name, :string, default: "")
    field(:event_name, :string)
    field(:sale_type, Ecto.Enum, values: [:public, :crew, :free, :member])
  end

  @spec get_last_transaction_id!() :: String.t() | nil
  def get_last_transaction_id!() do
    query =
      from(sale in __MODULE__,
        order_by: [desc: sale.created_at],
        limit: 1,
        select: [sale.transaction_id]
      )

    case Repo.one(query) do
      [transcation_id] -> transcation_id
      nil -> nil
    end
  end

  @spec get_transaction_id_by_date(DateTime.t()) :: String.t() | nil
  def get_transaction_id_by_date(date) do
    query =
      from(sale in __MODULE__,
        where: sale.created_at <= ^date,
        order_by: [desc: sale.created_at],
        limit: 1,
        select: [sale.transaction_id]
      )

    case Repo.one(query) do
      [transcation_id] -> transcation_id
      nil -> nil
    end
  end

  def changeset(transaction, params \\ %{}) do
    transaction
    |> cast(
      params,
      [
        :transaction_id,
        :status,
        :sold_by,
        :created_at,
        :currency,
        :amount,
        :amount_gross,
        :tip_amount,
        :description,
        :payment_method,
        :quantity,
        :event_name,
        :sale_type,
        :price_category_name,
        :created_at_local
      ]
    )
    |> validate_required([
      :transaction_id,
      :status,
      :sold_by,
      :created_at,
      :currency,
      :amount,
      :amount_gross,
      :payment_method,
      :quantity
    ])
    |> validate_number(:quantity, greater_than: 0)
  end
end
