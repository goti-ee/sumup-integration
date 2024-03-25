defmodule SumupIntegration.Worker do
  use Task

  alias SumupIntegration.Sales
  alias SumupIntegration.Pipeline.{EventDetector, SuperficialSaleRemoval, SaleTypeDetector}

  require Logger

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]},
      restart: :transient,
      significant: significant?()
    }
  end

  def run(_arg) do
    do_run(enabled?())
  end

  defp do_run(_enabled? = false), do: :ok

  defp do_run(_enabled? = true) do
    Sales.new()
    |> Sales.get_last_offset!()
    |> Sales.fetch!()
    |> Sales.run_pipeline!([
      &EventDetector.run/1,
      &SuperficialSaleRemoval.run/1,
      &SaleTypeDetector.run/1
    ])
    |> Sales.insert!()
  end

  defp significant?() do
    if Application.fetch_env!(:sumup_integration, :enabled_auto_exit?) do
      true
    else
      false
    end
  end

  defp enabled?() do
    opts = Application.fetch_env!(:sumup_integration, __MODULE__)

    Keyword.get(opts, :auto_fetch?, false)
  end
end
