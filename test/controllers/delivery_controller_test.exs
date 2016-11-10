defmodule Buckynix.DeliveryControllerTest do
  use Buckynix.ConnCase

  @valid_attrs %{date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, delivery_path(conn, :index)
    assert html_response(conn, 200)
  end
end
