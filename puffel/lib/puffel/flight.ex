defmodule Puffel.Flight do
  use Ecto.Schema

  @derive {Jason.Encoder, only: [:id, :origin, :destination]}

  schema "flight" do
    field(:origin)
    field(:destination)
  end
end
