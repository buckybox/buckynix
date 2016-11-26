defmodule Buckynix.Api.TransactionControllerTest do
  use Buckynix.ConnCase

  import Buckynix.Factory

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp relationships do
    %{}
  end

  @tag :skip
  test "lists all entries on index", %{conn: conn} do
    transaction = insert(:transaction)
    conn = get conn, api_user_transaction_path(conn, :index, 1)
    response = json_response(conn, 200)

    data = List.first response["data"]
    assert data["id"] == "#{transaction.id}"
    assert data["type"] == "transaction"
    assert data["attributes"]["description"] == transaction.description
    assert data["attributes"]["value_date"] == transaction.value_date
  end

  @tag :skip
  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, api_user_transaction_path(conn, :create, 1), %{
      "meta" => %{},
      "data" => %{
        "type" => "transaction",
        "attributes" => params_for(:transaction),
        "relationships" => relationships
      }
    }

    assert json_response(conn, 201)["data"]["id"]
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, api_user_transaction_path(conn, :create, 1), %{
      "meta" => %{},
      "data" => %{
        "type" => "transaction",
        "attributes" => %{},
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end
end
