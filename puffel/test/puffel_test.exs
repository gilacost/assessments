defmodule PuffelTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Puffel.Router.init([])

  test "returns pong if ping is requested" do
    conn = conn(:get, "/ping")

    conn = Puffel.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "pong"
  end

  test "GET /flights respond a list with available flights JSON encoded" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Puffel.Repo)
    flight = %Puffel.Flight{origin: "Barcelona", destination: "London"}
    Puffel.Repo.insert!(flight)

    conn = conn(:get, "/flights")

    conn = Puffel.Router.call(conn, @opts)
    expected = [%{"id" => 1, "origin" => "Barcelona", "destination" => "London"}]

    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == expected
  end
end
