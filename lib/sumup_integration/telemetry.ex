defmodule SumupIntegration.Telemetry do
  def setup do
    OpentelemetryEcto.setup([:sumup_integration, :repo])

    OpentelemetryOban.setup()
  end
end
