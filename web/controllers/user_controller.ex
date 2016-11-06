defmodule Buckynix.UserController do
  use Buckynix.Web, :controller

  alias Buckynix.{User,Account,Transaction}

  def index(conn, params) do
    count = Map.get(params, "count", 0)
    filter = Map.get(params, "filter", "")

    users = get_users(filter)
    users =
      users
      |> limit(^count)
      |> Repo.all
      |> Enum.map(fn(user) -> user_with_url_and_balance(conn, user) end)

    filter_count = Repo.aggregate(get_users(filter), :count, :id)
    total_count = Repo.aggregate(User, :count, :id)

    meta = %{
      "filter-count" => filter_count,
      "total-count" => total_count
    }

    render(conn, :index, data: users, opts: [meta: meta])
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    account = Repo.get_by!(Account, user_id: user.id)
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
    render(conn, "show.html", user: user, account: account, orders: orders, transactions: transactions)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end

  defp get_users(filter) do
    tag_regex = ~r/tag:(\w+)/
    tag = List.last(Regex.run(tag_regex, filter) || [])
    filter = String.strip Regex.replace(tag_regex, filter, "") # remove tag from filter

    query = from c in User,
      preload: [:account],
      where: ilike(c.name, ^"%#{filter}%")

    query |> User.with_tag(tag)
  end

  defp user_with_url_and_balance(conn, user) do
    %{user |
      url: user_path(conn, :show, user),
      balance: (Phoenix.HTML.safe_to_string Buckynix.Money.html(user.account.balance))
     }
  end
end
