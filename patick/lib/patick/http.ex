defmodule Patick.Http do
  @moduledoc """
  Helper module for http responses.

  A response contains data that is json encoded and its
  content type header `application/json`.

  """
  @error_messages %{
    bad_request: "Bad request",
    locked: "Resource locked",
    not_found: "Not found"
  }

  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3]

  @doc """
  Sends a 200 response.

  """
  @spec send_ok(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def send_ok(conn, resp_data), do: respond(conn, :ok, resp_data)

  @doc """
  Sends a 201 response.

  """
  @spec send_created(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def send_created(conn, resp_data), do: respond(conn, :created, resp_data)

  @doc """
  Sends a 400 response.

  """
  @spec send_bad(Plug.Conn.t()) :: Plug.Conn.t()
  def send_bad(conn, resp_data \\ ""), do: respond_error(conn, :bad_request, resp_data)

  @doc """
  Sends a 404 response.

  """
  @spec send_not_found(Plug.Conn.t()) :: Plug.Conn.t()
  def send_not_found(conn, resp_data \\ ""), do: respond_error(conn, :not_found, resp_data)

  @doc """
  Sends a 423 response.

  """
  @spec send_locked(Plug.Conn.t()) :: Plug.Conn.t()
  def send_locked(conn, resp_data \\ ""), do: respond_error(conn, :locked, resp_data)

  @spec respond(Plug.Conn.t(), atom, any()) :: Plug.Conn.t()
  defp respond(conn, status_code, resp_data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, Jason.encode!(resp_data))
  end

  @spec respond_error(Plug.Conn.t(), atom, any()) :: Plug.Conn.t()
  defp respond_error(conn, status, resp_data) do
    resp_data = %{
      "error" => %{
        "message" => "#{Map.get(@error_messages, status, "")}, #{resp_data}",
        "code" => Plug.Conn.Status.code(status)
      }
    }

    respond(conn, status, resp_data)
  end
end
