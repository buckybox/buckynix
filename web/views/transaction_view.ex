defmodule Buckynix.TransactionView do
  use Buckynix.Web, :view
  use JaSerializer.PhoenixView

  attributes [:description, :amount, :balance, :value_date, :inserted_at]
end
