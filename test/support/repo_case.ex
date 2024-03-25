defmodule SumupIntegration.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias SumupIntegration.Repo

      import Ecto
      import Ecto.Query
      import SumupIntegration.{RepoCase, Factory}
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SumupIntegration.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SumupIntegration.Repo, {:shared, self()})
    end

    :ok
  end
end
