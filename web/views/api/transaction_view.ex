defmodule Buckynix.Api.TransactionView do
  use JaSerializer.PhoenixView

  attributes [:description, :amount, :balance, :value_date, :inserted_at]

  def amount(transaction, _conn) do
    Buckynix.Money.html(transaction.amount)
    |> Phoenix.HTML.safe_to_string
  end

  def balance(transaction, _conn) do
    Buckynix.Money.html(transaction.balance)
    |> Phoenix.HTML.safe_to_string
  end
end
