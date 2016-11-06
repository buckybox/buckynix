defmodule Buckynix.CustomerControllerTest do
  use Buckynix.ConnCase

  alias Buckynix.Customer
  @valid_attrs %{email: "joe@test.local", name: "Joe"}
  @invalid_attrs %{name: ""}

  @account_attrs %{currency: "EUR"}

  setup context do
    user = Repo.insert! %Buckynix.User{name: "Name", email: "test@example.com"}
    conn = assign context[:conn], :current_user, user

    customer = case context[:with_customer] do
      true -> Customer.changeset(%Customer{}, @valid_attrs)
              |> put_assoc(:account, @account_attrs)
              |> Repo.insert!
      _ -> nil
    end

    [conn: conn, customer: customer, customer: customer]
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, customer_path(conn, :index)
    assert html_response(conn, 200) =~ "customers"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, customer_path(conn, :new)
    assert html_response(conn, 200) =~ "New customer"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, customer_path(conn, :create), customer: @valid_attrs
    assert redirected_to(conn) == customer_path(conn, :index)
    assert Repo.get_by(Customer, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, customer_path(conn, :create), customer: @invalid_attrs
    assert html_response(conn, 200) =~ "New customer"
  end

  @tag :with_customer
  test "shows chosen resource", %{conn: conn, customer: customer} do
    conn = get conn, customer_path(conn, :show, customer)
    assert html_response(conn, 200) =~ customer.name
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, customer_path(conn, :show, Ecto.UUID.generate)
    end
  end

  @tag :with_customer
  test "renders form for editing chosen resource", %{conn: conn, customer: customer} do
    conn = get conn, customer_path(conn, :edit, customer)
    assert html_response(conn, 200) =~ "Edit customer"
  end

  @tag :with_customer
  test "updates chosen resource and redirects when data is valid", %{conn: conn, customer: customer} do
    conn = put conn, customer_path(conn, :update, customer), customer: @valid_attrs
    assert redirected_to(conn) == customer_path(conn, :show, customer)
    assert Repo.get_by(Customer, @valid_attrs)
  end

  @tag :with_customer
  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, customer: customer} do
    conn = put conn, customer_path(conn, :update, customer), customer: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit customer"
  end

  @tag :with_customer
  test "deletes chosen resource", %{conn: conn, customer: customer} do
    conn = delete conn, customer_path(conn, :delete, customer)
    assert redirected_to(conn) == customer_path(conn, :index)
    refute Repo.get(Customer, customer.id)
  end
end
