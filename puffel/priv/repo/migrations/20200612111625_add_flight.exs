defmodule Puffel.Repo.Migrations.AddFlight do
  use Ecto.Migration

  def change do
    flight = %Puffel.Flight{origin: "Barcelona", destination: "London"}
    Puffel.Repo.insert!(flight)
  end
end
