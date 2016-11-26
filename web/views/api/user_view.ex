defmodule Buckynix.Api.UserView do
  use JaSerializer.PhoenixView

  location "/users/:id"
  attributes [:name, :balance, :tags]

  def balance(user, _conn) do
    Buckynix.Money.html(user.account.balance)
    |> Phoenix.HTML.safe_to_string
  end
end
