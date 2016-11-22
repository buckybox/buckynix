defmodule Buckynix.Api.TransactionController do
  use Buckynix.Web, :controller

  alias Buckynix.Transaction
  alias JaSerializer.Params

  plug :scrub_params, "data" when action in [:create]

  def index(conn, _params) do
    transactions = Transaction
      |> limit(5)
      |> Repo.all
      |> Enum.map(fn(transaction) -> transaction_with_balance(conn, transaction) end)

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

  defp transaction_with_balance(conn, transaction) do
    %{transaction |
      amount: (Phoenix.HTML.safe_to_string Buckynix.Money.html(transaction.amount)),
      balance: "$0.00"
     }
  end
end
