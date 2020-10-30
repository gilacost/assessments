defmodule Dpv.Repo.Migrations.AddCategoriesTable do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add(:name, :string)
      add(:parent_id, references(:categories))
    end

    create(index(:categories, [:parent_id]))
  end
end
