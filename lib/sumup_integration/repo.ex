defmodule SumupIntegration.Repo do
  use Ecto.Repo,
    otp_app: :sumup_integration,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    {:ok, Keyword.put(config, :url, System.get_env("DATABASE_URL"))}
  end
end
