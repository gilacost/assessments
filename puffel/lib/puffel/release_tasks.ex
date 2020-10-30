defmodule Puffel.ReleaseTasks do
  def migrate do
    {:ok, _} = Application.ensure_all_started(:puffel)

    path = Application.app_dir(:puffel, "priv/repo/migrations")

    Ecto.Migrator.run(Puffel.Repo, path, :up, all: true)
  end
end
