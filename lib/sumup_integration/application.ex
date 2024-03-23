defmodule SumupIntegration.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
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
