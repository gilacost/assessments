defmodule Patick.Repo do
  @moduledoc ~S"""
  Postgres repo that is started under the supervision tree
  and allows us to run queries throught `Ecto.Query` or
  `Ecto.Schema`. The database parameters can be found in
  the `config/`.


  """
  use Ecto.Repo,
    otp_app: :patick,
    adapter: Ecto.Adapters.Postgres
end
