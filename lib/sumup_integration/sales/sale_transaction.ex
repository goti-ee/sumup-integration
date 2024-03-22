defmodule SumupIntegration.Sales.SaleTransaction do
  use Ecto.Schema

  alias SumupIntegration.Repo

  import Ecto.Query
  import Ecto.Changeset

  @type transaction_status :: :successful | :failed | :refunded | :pending | :unknown
  @type payment_method :: :card | :cash | :unknown
  @type sale_type :: :public | :crew | :dj

  @type t :: %__MODULE__{
          transaction_id: String.t(),
          status: transaction_status(),
          sold_by: String.t(),
          created_at: DateTime.t(),
          currency: String.t(),
          amount: float(),
          description: String.t(),
          payment_method: payment_method(),
          quantity: pos_integer(),
          event_name: String.t() | nil,
          sale_type: sale_type() | nil
        }

  schema "sale_transactions" do
    field(:transaction_id, :string)
    field(:status, Ecto.Enum, values: [:successful, :failed, :refunded, :pending, :unknown])
    field(:sold_by, :string)
    field(:created_at, :utc_datetime)
    field(:currency, :string)
    field(:amount, :decimal)
    field(:description, :string, default: "")
    field(:payment_method, Ecto.Enum, values: [:card, :cash, :unknown])
    field(:quantity, :integer)
    field(:event_name, :string)
    field(:sale_type, Ecto.Enum, values: [:public, :crew, :dj])
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
        :description,
        :payment_method,
        :quantity,
        :event_name,
        :sale_type
      ]
    )
    |> validate_required([
      :transaction_id,
      :status,
      :sold_by,
      :created_at,
      :currency,
      :amount,
      :payment_method,
      :quantity
    ])
    |> validate_number(:quantity, greater_than: 0)
  end
end
