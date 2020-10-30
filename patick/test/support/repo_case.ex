defmodule Patick.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Patick.{Repo, Ticket}

      import Ecto
      import Ecto.Query
      import Patick.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Patick.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Patick.Repo, {:shared, self()})
    end

    :ok
  end
end
