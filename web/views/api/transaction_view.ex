defmodule Buckynix.Api.TransactionView do
  use JaSerializer.PhoenixView

  attributes [:description, :amount, :balance, :value_date, :inserted_at]
end
