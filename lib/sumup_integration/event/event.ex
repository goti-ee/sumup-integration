defmodule SumupIntegration.Event do
  use Ecto.Schema

  import Ecto.Query

  @type t :: %__MODULE__{
          name: String.t(),
          start_at: DateTime.t(),
          end_at: DateTime.t()
        }

  schema "events" do
    field(:name, :string)
    field(:start_at, :utc_datetime)
    field(:end_at, :utc_datetime)
  end

  @spec get_all() :: [t()]
  def get_all() do
    query = from(__MODULE__)

    SumupIntegration.Repo.all(query)
  end
end
