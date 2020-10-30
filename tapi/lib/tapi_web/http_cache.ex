defmodule TapiWeb.HttpCache do
  @moduledoc """
  TODO
  """
  import Plug.Conn

  @cache_control "private"

  @doc false
  def init([]), do: []

  @type conn :: Plug.Conn.t()

  @doc """
  TODO
  """
  @spec call(conn, Keyword.t()) :: conn
  def call(conn, _opts) do
    with [last_modified] when not is_nil(last_modified) <-
           get_req_header(conn, "if-modified-since"),
         :eq <- compare_with_today(last_modified) do
      conn
      |> put_resp_header("cache-control", @cache_control)
      |> put_resp_header("last-modified", last_modified)
      |> resp(304, "")
      |> halt()
    else
      _ ->
        last_modified = "GMT" |> Timex.now() |> Timex.format!("{RFC1123}")

        conn
        |> put_resp_header("cache-control", @cache_control)
        |> put_resp_header("last-modified", last_modified)
    end
  end

  @spec compare_with_today(String.t()) :: :lt | :eq | :gt
  defp compare_with_today(last_modified) do
    today = "GMT" |> Timex.now() |> DateTime.to_date()

    last_modified
    |> Timex.parse("{RFC1123}")
    |> case do
      {:ok, date_time} ->
        DateTime.to_date(date_time)

      {:error, _term} ->
        Date.add(today, -1)
    end
    |> Date.compare(today)
  end
end
