defmodule Vdp.Category do
  @moduledoc """
  TODO
  """
  use Ecto.Schema
  import Ecto.Query
  alias Vdp.{Repo, Category}

  schema "categories" do
    field :name, :string
    belongs_to :parent, Category
  end

  @doc """
  TODO
  """
  def last_inserted_by(:name, name) do
    q =
      from c in Category,
        where: c.name == ^name,
        order_by: [desc: c.id],
        limit: 1

    Repo.one(q)
  end
end
