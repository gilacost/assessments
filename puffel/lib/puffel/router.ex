defmodule Puffel.Router do
  use Plug.Router

  plug(Plug.Logger)

  plug(Puffel.Metrics.PlugExporter)
  plug(Puffel.Metrics.PipelineInstrumenter)

  plug(:match)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  get "/flights" do
    flight_list = Puffel.Flight |> Ecto.Query.first() |> Puffel.Repo.all()
    send_resp(conn, 200, Jason.encode!(flight_list))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end

defmodule MyPlugLables do
  def label_value(:request_path, conn) do
    conn.request_path
  end
end
