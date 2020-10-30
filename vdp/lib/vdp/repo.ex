defmodule Vdp.Repo do
  use Ecto.Repo,
    otp_app: :vdp,
    adapter: Ecto.Adapters.Postgres
end
