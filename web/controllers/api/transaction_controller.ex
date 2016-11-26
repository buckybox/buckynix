defmodule Buckynix.Api.TransactionController do
  use Buckynix.Web, :controller

  alias Buckynix.Transaction
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create]

  def index(conn, %{"user_id" => user_id}) do
    current_organization = Map.fetch!(conn.assigns, :current_organization)
    users = assoc(current_organization, :users)
    user = Repo.get!(users, user_id)
    account = assoc(user, :account) |> Repo.one!
    transactions =
      assoc(account, :transactions)
      |> order_by([desc: :value_date])
      |> Repo.all
      |> compute_balances(account.balance)

    render(conn, "index.json-api", data: transactions)
  end

  def create(conn, %{"data" => data = %{"type" => "transaction", "attributes" => _transaction_params}}) do
    changeset = Transaction.changeset(%Transaction{}, Params.to_attributes(data))

    case Repo.insert(changeset) do
      {:ok, transaction} ->
        conn
        |> put_status(:created)
        |> render("show.json-api", data: transaction)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  defp compute_balances(transactions, current_balance) do
    transactions |> Enum.map(
      fn(transaction) ->
        %{transaction | balance: Enum.reduce_while(
          transactions, current_balance,
          fn(other_transaction, acc) ->
            if other_transaction.value_date <= transaction.value_date do
              {:halt, acc}
            else
              {:cont, Money.subtract(acc, other_transaction.amount)}
            end
          end
        )}
      end
    )
  end
end
