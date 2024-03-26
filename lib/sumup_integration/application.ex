defmodule SumupIntegration.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    if Application.get_env(:sumup_integration, :testcontainers, false) do
      {:ok, _container} = Testcontainers.Ecto.postgres_container(app: :sumup_integration)
    end

    children = [
      SumupIntegration.Repo,
      {SumupIntegration.Worker, []}
    ]

    opts = [
      strategy: :one_for_one,
      name: SumupIntegration.Supervisor,
      auto_shutdown: auto_shutdown()
    ]

    Supervisor.start_link(children, opts)
  end

  defp auto_shutdown() do
    if Application.fetch_env!(:sumup_integration, :enabled_auto_exit?) do
      :any_significant
    else
      :never
    end
  end
end
