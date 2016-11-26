defmodule Buckynix.Api.UserControllerTest do
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
  test "lists all entries on index", %{conn: conn, user: user} do
    conn = get conn, api_user_path(conn, :index)
    response = json_response(conn, 200)

    data = Map.fetch!(response, "data") |> List.last
    assert data["id"] == "#{user.id}"
    assert data["type"] == "user"
    assert data["attributes"]["name"] == user.name
  end
end
