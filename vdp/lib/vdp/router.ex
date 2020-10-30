defmodule Dpv.Router do
  @moduledoc """
  TODO
  """
  use Plug.Router

  plug :match
  plug :dispatch

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass: ["text/*"],
    json_decoder: Jason

  get "/search/data-categories" do
    %{query_params: %{"q" => q}} = conn = Plug.Conn.fetch_query_params(conn)

    response =
      Jason.encode!(%{
        "searchTerm" => q,
        "results" => Dpv.build_category_tree("#{q}%")
      })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
