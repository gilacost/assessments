defmodule Puffel.Repo.Migrations.Flight do
  use Ecto.Migration

  def change do
    create table(:flight) do
      add(:origin, :string)
      add(:destination, :string)
    end
  end
end
