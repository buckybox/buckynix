defmodule Buckynix.HomeControllerTest do
  use Buckynix.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Buckynix!"
  end
end
