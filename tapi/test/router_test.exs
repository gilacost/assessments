defmodule TapiWeb.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias TapiWeb.ApiRouter

  @opts ApiRouter.init([])

  @valid_endpoints [
    "/accounts",
    "/accounts/test_acc_sGlFU3ZT",
    "/accounts/test_acc_sGlFU3ZT/transactions"
  ]

  @unexisting_endpoints [
    "/accounts/test_acc_sGlFU3Z",
    "/accounts/test_acc_sGlFU3Z/transactions"
  ]

  test "endpoints exist and response has JSON as content type header" do
    Enum.each(@valid_endpoints, fn endpoint ->
      conn = build_conn_with_token("test_user", "", endpoint)
      conn = ApiRouter.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 200

      assert conn
             |> get_resp_header("content-type")
             |> List.first() =~ "application/json"
    end)
  end

  test "not found" do
    Enum.each(@unexisting_endpoints, fn endpoint ->
      conn = build_conn_with_token("test_user", "", endpoint)
      conn = ApiRouter.call(conn, @opts)

      assert conn.state == :sent
      assert conn.status == 404

      assert conn.resp_body ==
               Jason.encode!(%{
                 "error" => %{
                   "message" => "Not found",
                   "code" => 404
                 }
               })
    end)
  end

  describe "basic auth token" do
    test "contains user with test_ as prefix" do
      conn = build_conn_with_token("no test_ prefix", "")

      assert conn.status == 401
    end

    test "password is empty" do
      conn = build_conn_with_token("test_user", "no empty")

      assert conn.status == 401
    end

    test "contains seed and is an integer generated from the user in the barer" do
      base = "user" |> String.to_charlist() |> Enum.sum()
      expected_seed = {base, base + 1, base + 2}

      conn = build_conn_with_token("test_user", "")

      assert conn.assigns[:seeds] |> List.first() == expected_seed
    end
  end

  defp build_conn_with_token(user_name, password, endpoint \\ "/") do
    token = Plug.BasicAuth.encode_basic_auth(user_name, password)

    :get
    |> conn(endpoint)
    |> Plug.Conn.put_req_header("authorization", token)
    |> TapiWeb.BasicAuth.call([])
  end
end
