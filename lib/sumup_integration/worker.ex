defmodule SumupIntegration.Worker do
  use Task, restart: :transient

  alias SumupIntegration.Sales
  alias SumupIntegration.Pipeline.EventDetector

  require Logger

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(_arg) do
    # Sales.new()
    # |> Sales.get_last_offset!()
    # |> Sales.fetch!()
    # |> Sales.run_pipeline!([
    #   &EventDetector.run/1
    # ])
    # |> Sales.insert!()

    # SumupSales.get_cached_sales!()
    # |> dbg
  end
end
