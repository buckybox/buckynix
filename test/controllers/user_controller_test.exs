defmodule Buckynix.UserControllerTest do
  use Buckynix.ConnCase

  alias Buckynix.User

  @valid_attrs params_for(:user)
  @invalid_attrs %{name: ""}

  setup context do
    current_user = insert(:user, account: build(:account))
    conn = assign context[:conn], :current_user, current_user

    user = if context[:with_user] do
      insert(:user, account: build(:account))
    else
      nil
    end

    [conn: conn, user: user]
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "elm-user-list-app"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, email: @valid_attrs.email)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  @tag :with_user
  test "shows chosen resource", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ user.name
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, Ecto.UUID.generate)
    end
  end

  @tag :with_user
  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag :with_user
  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, email: @valid_attrs.email)
  end

  @tag :with_user
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag :skip
  @tag :with_user
  test "archives chosen resource", %{conn: conn, user: user} do
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    user = Repo.get!(User, user.id)
    refute is_nil(user.archived_at)
  end
end
