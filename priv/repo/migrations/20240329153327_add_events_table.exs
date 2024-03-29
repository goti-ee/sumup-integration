defmodule SumupIntegration.Repo.Migrations.AddEventsTable do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :start_at, :utc_datetime, null: false
      add :end_at, :utc_datetime, null: false
    end

    create unique_index(:events, [:name])
  end
end
