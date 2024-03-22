defmodule SumupIntegration.Repo.Migrations.CreateSaleTransaction do
  use Ecto.Migration

  def change do
    create table(:sale_transactions) do
      add :transaction_id, :string, null: false
      add :status, :string, null: false
      add :sold_by, :string, null: false
      add :created_at, :utc_datetime, null: false
      add :currency, :string, null: false
      add :amount, :decimal, null: false
      add :description, :string, null: true, default: ""
      add :payment_method, :string, null: false
      add :quantity, :integer, null: false
      add :event_name, :string, null: true
      add :sale_type, :string, null: true
    end

    create unique_index(:sale_transactions, [:transaction_id, :description, :quantity])
  end
end
