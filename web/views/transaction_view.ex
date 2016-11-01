defmodule Buckynix.TransactionView do
  use Buckynix.Web, :view
  use JaSerializer.PhoenixView

  attributes [:description, :value_date, :inserted_at, :updated_at]
end
