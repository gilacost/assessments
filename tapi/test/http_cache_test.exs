defmodule TapiWeb.HttpCacheTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias TapiWeb.HttpCache

  describe "Not modified" do
    test "if-modified-since is from today responds not modified and maintains last-modified" do
      now = "GMT" |> Timex.now() |> Timex.format!("{RFC1123}")

      conn = build_with_not_modified_since(now)

      assert conn.state == :set
      assert conn.status == 304
      [last_modified] = Plug.Conn.get_resp_header(conn, "last-modified")
      assert last_modified == now
    end

    test "if-modified-since is from other day than today updates last-modified" do
      now = "GMT" |> Timex.now() |> Timex.format!("{RFC1123}")

      other_day =
        "GMT"
        |> Timex.now()
        |> Timex.shift(hours: -25)
        |> Timex.format!("{RFC1123}")

      conn = build_with_not_modified_since(other_day)

      assert conn.state == :unset
      refute conn.status == 304
      [last_modified] = Plug.Conn.get_resp_header(conn, "last-modified")
      assert last_modified == now
      refute last_modified == other_day
    end
  end

  test "always contains cache-control header and is private" do
    now = "GMT" |> Timex.now() |> Timex.format!("{RFC1123}")

    conn = build_with_not_modified_since(now)

    [cache_control] = Plug.Conn.get_resp_header(conn, "cache-control")
    assert cache_control == "private"

    :get
    |> conn("/")
    |> HttpCache.call([])

    [cache_control] = Plug.Conn.get_resp_header(conn, "cache-control")
    assert cache_control == "private"
  end

  @spec build_with_not_modified_since(String.t()) :: Plug.Conn.t()
  defp build_with_not_modified_since(strtime) do
    :get
    |> conn("/")
    |> Plug.Conn.put_req_header("if-modified-since", strtime)
    |> HttpCache.call([])
  end
end
