defmodule Buckynix.TransactionControllerTest do
  use Buckynix.ConnCase

  alias Buckynix.Transaction
  alias Buckynix.Repo

  @valid_attrs %{amount: 1234, description: "some content", value_date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  setup do
    conn = build_conn()
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  defp relationships do
    %{}
  end

  test "lists all entries on index", %{conn: conn} do
    transaction = Repo.insert! Transaction.changeset(%Transaction{}, @valid_attrs)
    conn = get conn, user_transaction_path(conn, :index, 1)
    response = json_response(conn, 200)

    data = List.first response["data"]
    assert data["id"] == "#{transaction.id}"
    assert data["type"] == "transaction"
    assert data["attributes"]["description"] == transaction.description
    assert data["attributes"]["value_date"] == transaction.value_date
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_transaction_path(conn, :create, 1), %{
      "meta" => %{},
      "data" => %{
        "type" => "transaction",
        "attributes" => @valid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Transaction, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_transaction_path(conn, :create, 1), %{
      "meta" => %{},
      "data" => %{
        "type" => "transaction",
        "attributes" => @invalid_attrs,
        "relationships" => relationships
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end
end
