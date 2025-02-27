defmodule SumupIntegration.Sales do
  require Logger

  alias SumupIntegration.Repo
  alias SumupIntegration.Sales.{ApiTransaction, SaleTransaction}

  alias SumupIntegration.Pipeline.{
    EventDetector,
    SuperficialSaleRemoval,
    SaleTypeDetector,
    DescriptionNormalizer,
    SumupFeeReducer,
    TimestampLocalization
  }

  @type pipeline_callback :: ([SaleTransaction] -> [SaleTransaction])
  @type t :: %__MODULE__{
          transactions: [SaleTransaction.t()] | nil,
          last_fetched_id: String.t() | nil
        }

  defstruct [:transactions, :last_fetched_id]

  @default_pipeline [
    &EventDetector.run/1,
    &DescriptionNormalizer.run/1,
    &SuperficialSaleRemoval.run/1,
    &SaleTypeDetector.run/1,
    &SumupFeeReducer.run/1,
    &TimestampLocalization.run/1
  ]

  def new() do
    %__MODULE__{}
  end

  @spec get_offset!(t(), relative_timestamp :: :last | :first | :month_ago) :: t()
  def get_offset!(%__MODULE__{} = sales, relative_timestamp) do
    transaction_id =
      case relative_timestamp do
        :last ->
          SaleTransaction.get_last_transaction_id!()

        :first ->
          nil

        :month_ago ->
          DateTime.utc_now()
          |> DateTime.add(-30, :day)
          |> SaleTransaction.get_transaction_id_by_date()
      end

    Logger.info("Storing remote offset as starting point", transaction_id: transaction_id)

    %__MODULE__{sales | last_fetched_id: transaction_id}
  end

  def fetch!(%__MODULE__{last_fetched_id: last_fetched_id} = sales) do
    transactions =
      ApiTransaction.fetch!(last_fetched_id)
      |> Enum.map(&ApiTransaction.to_sale_transaction!(&1))
      |> Enum.map(&SaleTransaction.changeset(%SaleTransaction{}, &1))
      |> Enum.map(&Ecto.Changeset.apply_action!(&1, :update))

    %__MODULE__{sales | transactions: transactions}
  end

  @spec run_pipeline!(t(), [pipeline_callback()]) :: t()
  @spec run_pipeline!(t()) :: t()
  def run_pipeline!(
        %__MODULE__{transactions: transactions} = sales,
        pipeline \\ @default_pipeline
      ) do
    next_transactions =
      pipeline
      |> Enum.reduce(transactions, fn pipeline_stage, agg ->
        pipeline_stage.(agg)
      end)

    %__MODULE__{sales | transactions: next_transactions}
  end

  def insert!(%__MODULE__{transactions: transactions} = sales) do
    Repo.transaction(fn ->
      transactions
      |> Enum.map(
        &Repo.insert!(
          &1,
          on_conflict: {:replace_all_except, [:id]},
          conflict_target: [:transaction_id, :description, :quantity]
        )
      )
    end)

    sales
  end

  @spec to_transactions(t()) :: [SaleTransaction.t()]
  def to_transactions(%__MODULE__{transactions: transactions}), do: transactions
end
