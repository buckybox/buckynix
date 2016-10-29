defmodule Buckynix.CustomerController do
  use Buckynix.Web, :controller

  alias Buckynix.{Customer,Account,Transaction}

  def tag(conn, %{"tag" => tag}) do
    customers = Repo.all(
      from c in Customer,
      where: fragment("? = ANY (tags)", ^tag),
      preload: [:account]
    )
    render(conn, "index.html", customers: customers)
  end

  def search(conn, %{"search" => %{"query" => query}}) do
    customers = Repo.all(
      from c in Customer,
      where: ilike(c.name, ^"%#{query}%"),
      preload: [:account]
    )
    render(conn, "index.html", customers: customers)
  end

  def index(conn, _params) do
    customers = Customer
      |> preload(:account)
      |> Repo.all
    render(conn, "index.html", customers: customers)
  end

  def new(conn, _params) do
    changeset = Customer.changeset(%Customer{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"customer" => customer_params}) do
    changeset = Customer.changeset(%Customer{}, customer_params)

    case Repo.insert(changeset) do
      {:ok, _customer} ->
        conn
        |> put_flash(:info, "Customer created successfully.")
        |> redirect(to: customer_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    customer = Repo.get!(Customer, id)
    account = Repo.get_by!(Account, customer_id: customer.id)
    orders = []
    transactions = Repo.all(Transaction, account_id: account.id)
    # TODO: must be a cleaner way to fetch this - with preload?
    render(conn, "show.html", customer: customer, account: account, orders: orders, transactions: transactions)
  end

  def edit(conn, %{"id" => id}) do
    customer = Repo.get!(Customer, id)
    changeset = Customer.changeset(customer)
    render(conn, "edit.html", customer: customer, changeset: changeset)
  end

  def update(conn, %{"id" => id, "customer" => customer_params}) do
    customer = Repo.get!(Customer, id)
    changeset = Customer.changeset(customer, customer_params)

    case Repo.update(changeset) do
      {:ok, customer} ->
        conn
        |> put_flash(:info, "Customer updated successfully.")
        |> redirect(to: customer_path(conn, :show, customer))
      {:error, changeset} ->
        render(conn, "edit.html", customer: customer, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    customer = Repo.get!(Customer, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(customer)

    conn
    |> put_flash(:info, "Customer deleted successfully.")
    |> redirect(to: customer_path(conn, :index))
  end
end
