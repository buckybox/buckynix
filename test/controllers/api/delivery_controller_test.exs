defmodule Buckynix.Api.DeliveryControllerTest do
  use Buckynix.ConnCase

  @valid_attrs params_for(:delivery)
  @invalid_attrs %{}

  setup %{conn: conn, with_delivery: true} do
    organization = insert(:organization)
    user = insert(:user, address: build(:address))
    user
    |> Repo.preload(:organizations)
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:organizations, [organization])
    |> Repo.update!

    conn =  assign(conn, :current_user, user)
         |> assign(:current_organization, organization)

    delivery = insert(:delivery, user: user)
    delivery
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_embed(:address, user.address)
    |> Repo.update!

    [conn: conn, user: user, delivery: delivery]
  end

  @tag :with_delivery
  test "lists all entries on index", %{conn: conn, delivery: delivery} do
    date = delivery.date |> Timex.format!("%F", :strftime)
    filter = %{from: date, to: date}
    conn = get conn, api_delivery_path(conn, :index, filter: filter)
    response = json_response(conn, 200)

    data = Map.fetch!(response, "data") |> List.last
    assert data["id"] == "#{delivery.id}"
    assert data["type"] == "delivery"
    assert data["attributes"]["address"]

    included = Map.fetch!(response, "included") |> List.last
    assert included["type"] == "user"
    assert included["links"]["self"]
  end
end
