defmodule SumupIntegration.Worker do
  use Oban.Worker,
    max_attempts: 1,
    unique: [period: :infinity, states: ~w(available executing)a]

  alias SumupIntegration.Sales

  alias SumupIntegration.Pipeline.{
    EventDetector,
    SuperficialSaleRemoval,
    SaleTypeDetector,
    DescriptionNormalizer
  }

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{} = _job) do
    do_perform(enabled?())
  end

  defp do_perform(_enabled? = false), do: :ok

  defp do_perform(_enabled? = true) do
    Sales.new()
    |> Sales.get_last_offset!()
    |> Sales.fetch!()
    |> Sales.run_pipeline!([
      &EventDetector.run/1,
      &DescriptionNormalizer.run/1,
      &SuperficialSaleRemoval.run/1,
      &SaleTypeDetector.run/1
    ])
    |> Sales.insert!()

    :ok
  end

  defp enabled?() do
    opts = Application.fetch_env!(:sumup_integration, __MODULE__)

    Keyword.get(opts, :auto_fetch?, false)
  end
end
