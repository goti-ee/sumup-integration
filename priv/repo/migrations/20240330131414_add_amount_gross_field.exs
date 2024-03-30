defmodule SumupIntegration.Repo.Migrations.AddAmountGrossField do
  use Ecto.Migration

  def up do
    alter table("sale_transactions") do
      add :amount_gross, :float, null: true
    end

    flush()

    SumupIntegration.Repo.query!('UPDATE sale_transactions SET amount_gross = amount')

    alter table("sale_transactions") do
      modify :amount_gross, :float, null: false
    end
  end

  def down do
    alter table("sale_transactions") do
      remove :amount_gross
    end
  end
end
