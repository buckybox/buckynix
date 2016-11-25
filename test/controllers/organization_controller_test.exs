defmodule Buckynix.OrganizationControllerTest do
  use Buckynix.ConnCase

  alias Buckynix.Organization
  @valid_attrs params_for(:organization)
  @invalid_attrs %{name: ""}

  setup context do
    user = insert(:user)
    conn = assign context[:conn], :current_user, user

    organization = case context[:with_organization] do
      true -> insert(:organization)
      _ -> nil
    end

    [conn: conn, organization: organization]
  end

  @tag :with_organization
  test "lists all entries on index", %{conn: conn} do
    conn = get conn, organization_path(conn, :index)
    assert html_response(conn, 200)
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, organization_path(conn, :new)
    assert html_response(conn, 200) =~ "New organization"
  end

  @tag :skip
  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, organization_path(conn, :create), organization: @valid_attrs
    assert redirected_to(conn) == organization_path(conn, :index)
    assert Repo.get_by(Organization, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, organization_path(conn, :create), organization: @invalid_attrs
    assert html_response(conn, 200) =~ "New organization"
  end

  @tag :with_organization
  test "redirects to admin panel", %{conn: conn, organization: organization} do
    conn = get conn, organization_path(conn, :show, organization)
    assert redirected_to(conn) == user_path(conn, :index)
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, organization_path(conn, :show, Ecto.UUID.generate)
    end
  end

  @tag :with_organization
  test "renders form for editing chosen resource", %{conn: conn, organization: organization} do
    conn = get conn, organization_path(conn, :edit, organization)
    assert html_response(conn, 200) =~ "Edit organization"
  end

  @tag :skip
  @tag :with_organization
  test "updates chosen resource and redirects when data is valid", %{conn: conn, organization: organization} do
    conn = put conn, organization_path(conn, :update, organization), organization: @valid_attrs
    assert redirected_to(conn) == organization_path(conn, :show, organization)
    assert Repo.get_by(Organization, @valid_attrs)
  end

  @tag :with_organization
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, organization: organization} do
    conn = put conn, organization_path(conn, :update, organization), organization: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit organization"
  end

  @tag :with_organization
  test "deletes chosen resource", %{conn: conn, organization: organization} do
    conn = delete conn, organization_path(conn, :delete, organization)
    assert redirected_to(conn) == organization_path(conn, :index)
    refute Repo.get(Organization, organization.id)
  end
end
