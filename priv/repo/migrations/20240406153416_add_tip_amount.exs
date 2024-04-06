defmodule SumupIntegration.Repo.Migrations.AddTipAmount do
  use Ecto.Migration

  def change do
    alter table("sale_transactions") do
      add :tip_amount, :float, null: true
    end
  end
end
