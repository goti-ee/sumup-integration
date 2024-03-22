defmodule SumupIntegration.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SumupIntegration.Repo,
      {SumupIntegration.Worker, []}
    ]

    #  auto_shutdown: :any_significant
    opts = [strategy: :one_for_one, name: SumupIntegration.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
