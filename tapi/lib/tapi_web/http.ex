defmodule TapiWeb.Http do
  @moduledoc """
  Helper module for http responses and routes.

  A response contains data that is json encoded and its
  content type header `application/json`.

  """
  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3]

  @port Application.get_env(:tapi, :api_port)

  @doc """
  Sends a 200 response.

  """
  @spec send_ok(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def send_ok(conn, resp_data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:ok, Jason.encode!(resp_data))
  end

  @doc """
  Sends a 404 response.

  """
  @spec send_not_found(Plug.Conn.t()) :: Plug.Conn.t()
  def send_not_found(conn) do
    resp_data = %{
      "error" => %{
        "message" => "Not found",
        "code" => 404
      }
    }

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:not_found, Jason.encode!(resp_data))
  end

  @type params :: Tapi.Random.id() | list(Tapi.Random.id())

  @doc """
  Constructs the route from an endpoint and an id.

  ## Examples

      iex> TapiWeb.Http.route_for(:account, "ACCOUNT_ID")
      "http://localhost:4002/accounts/ACCOUNT_ID"

  """
  @spec route_for(atom, params) :: String.t()
  def route_for(endpoint, params) do
    case {endpoint, params} do
      {:account, id} ->
        "http://localhost:#{to_string(@port)}/accounts/#{id}"

      {:transactions, [account_id, id]} ->
        "http://localhost:#{to_string(@port)}/accounts/#{account_id}/transactions/#{id}"

      {:transactions, id} ->
        "http://localhost:#{to_string(@port)}/accounts/#{id}/transactions"
    end
  end
end
