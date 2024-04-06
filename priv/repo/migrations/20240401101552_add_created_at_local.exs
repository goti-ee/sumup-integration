defmodule SumupIntegration.Repo.Migrations.AddCreatedAtLocal do
  use Ecto.Migration

  def change do
    alter table("sale_transactions") do
      add :created_at_local, :naive_datetime, null: true
    end
  end
end
