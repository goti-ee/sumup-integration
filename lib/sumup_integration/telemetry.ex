defmodule SumupIntegration.Telemetry do
  def setup do
    OpentelemetryEcto.setup([:sumup_integration, :repo])

    # Only trace jobs to minimize noise
    OpentelemetryOban.setup(trace: [:jobs])
  end
end
