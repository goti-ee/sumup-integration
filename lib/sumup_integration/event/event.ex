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

  @spec delete_by_id(integer()) :: {non_neg_integer(), nil | term()}
  @spec delete_by_id(list(integer())) :: {non_neg_integer(), nil | term()}
  def delete_by_id(ids) when is_list(ids) do
    query = from(e in __MODULE__, where: e.id in ^ids)

    SumupIntegration.Repo.delete_all(query)
  end

  def delete_by_id(id) when is_integer(id), do: delete_by_id([id])
end
