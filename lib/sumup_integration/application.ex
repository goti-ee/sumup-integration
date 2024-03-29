defmodule SumupIntegration.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Oban.Telemetry.attach_default_logger()

    if Application.get_env(:sumup_integration, :testcontainers, false) do
      {:ok, _container} = Testcontainers.Ecto.postgres_container(app: :sumup_integration)
    end

    children = [
      SumupIntegration.Repo,
      {Oban, Application.fetch_env!(:sumup_integration, Oban)}
    ]

    opts = [
      strategy: :one_for_one,
      name: SumupIntegration.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
