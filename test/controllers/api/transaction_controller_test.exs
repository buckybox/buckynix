defmodule Buckynix.Api.TransactionControllerTest do
  use Buckynix.ConnCase

  import Buckynix.Factory

  setup %{conn: conn, with_user: true} do
    organization = insert(:organization)
    user = insert(:user, account: build(:account))
    user
    |> Repo.preload(:organizations)
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:organizations, [organization])
    |> Repo.update!

    conn =  assign(conn, :current_user, user)
         |> assign(:current_organization, organization)

    [conn: conn, user: user]
  end

  @tag :with_user
  test "lists all user's transactions on index", %{conn: conn, user: user} do
    account = user.account
    transaction = insert(:transaction, account: account)

    conn = get conn, api_user_transaction_path(conn, :index, user.id)
    response = json_response(conn, 200)

    data = Map.fetch!(response, "data") |> List.last
    assert data["id"] == "#{transaction.id}"
    assert data["type"] == "transaction"
    assert data["attributes"]["description"] == transaction.description
    assert data["attributes"]["value-date"] == Ecto.DateTime.to_iso8601 transaction.value_date
  end

  @tag :skip
  @tag :with_user
  test "creates and renders resource when data is valid", %{conn: conn, user: user} do
    conn = post conn, api_user_transaction_path(conn, :create, 1), %{
      "meta" => %{},
      "data" => %{
        "type" => "transaction",
        "attributes" => params_for(:transaction),
        "relationships" => %{}
      }
    }

    assert json_response(conn, 201)["data"]["id"]
  end

  @tag :skip
  @tag :with_user
  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = post conn, api_user_transaction_path(conn, :create, 1), %{
      "meta" => %{},
      "data" => %{
        "type" => "transaction",
        "attributes" => %{},
        "relationships" => %{}
      }
    }

    assert json_response(conn, 422)["errors"] != %{}
  end
end
