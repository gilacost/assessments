defmodule Puffel.Repo do
  use Ecto.Repo,
    otp_app: :puffel,
    adapter: Ecto.Adapters.Postgres
end
