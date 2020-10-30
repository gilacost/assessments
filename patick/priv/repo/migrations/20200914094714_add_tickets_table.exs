defmodule Patick.Repo.Migrations.AddTicketsTable do
  use Ecto.Migration

  def change do
    create table("tickets") do
      add(:code, :string, size: 16)

      timestamps()
    end
  end
end
