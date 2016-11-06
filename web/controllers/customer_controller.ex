defmodule Buckynix.CustomerController do
  use Buckynix.Web, :controller

  alias Buckynix.{Customer,Account,Transaction}

  def index(conn, params) do
    count = Map.get(params, "count", 0)
    filter = Map.get(params, "filter", "")

    customers = get_customers(filter)
    customers =
      customers
      |> limit(^count)
      |> Repo.all
      |> Enum.map(fn(customer) -> customer_with_url_and_balance(conn, customer) end)

    filter_count = Repo.aggregate(get_customers(filter), :count, :id)
    total_count = Repo.aggregate(Customer, :count, :id)

    meta = %{
      "filter-count" => filter_count,
      "total-count" => total_count
    }

    render(conn, :index, data: customers, opts: [meta: meta])
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

    transactions = Repo.all(
      from t in Transaction,
      where: t.account_id == ^account.id,
      order_by: [desc: :value_date]
    )

    transactions = transactions |> Enum.map(
      fn(tx) ->
        %{tx | balance: Enum.reduce_while(transactions, account.balance, fn(tx2, acc) ->
          if tx2.value_date <= tx.value_date, do: {:halt, acc}, else: {:cont, Money.subtract(acc, tx2.amount)}
        end
        )}
      end
    )

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

  defp customer_with_url_and_balance(conn, customer) do
    %{customer |
      url: customer_path(conn, :show, customer),
      balance: (Phoenix.HTML.safe_to_string Buckynix.Money.html(customer.account.balance))
     }
  end

  defp get_customers(filter) do
    tag_regex = ~r/tag:(\w+)/
    tag = List.last(Regex.run(tag_regex, filter) || [])
    filter = String.strip Regex.replace(tag_regex, filter, "") # remove tag from filter

    query = from c in Customer,
      preload: [:account],
      where: ilike(c.name, ^"%#{filter}%")

    query |> Customer.with_tag(tag)
  end
end
