# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Buckynix.Repo.insert!(%Buckynix.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Buckynix.{Repo, User, Customer}

users = [
  %{
    name: "John Doe",
    email: "john@example.net",
    password: "rubbish",
    password_confirmation: "rubbish"
  },
  %{
    name: "Bob Carrot",
    email: "bob@carrot.net",
    password: "rubbish",
    password_confirmation: "rubbish"
  },
  %{
    name: "Buck Baller",
    email: "buck@baller.xyz",
    password: "rubbish",
    password_confirmation: "rubbish"
  },
]
|> Enum.map(&User.changeset(%User{}, &1))
|> Enum.map(&Repo.insert!(&1))

customers = for i <- 1..Enum.random(10..20) do
  Customer.changeset(%Customer{}, %{ name: "Customer #{i}", email: "c#{i}@example.net", tags: ~w(test baller) })
  |> Repo.insert!
end

accounts = customers
|> Enum.map(&Ecto.build_assoc(&1, :account, %{currency: "EUR"}))
|> Enum.map(&Repo.insert!(&1))

for i <- Enum.random(2..4)..0 do
  transactions = accounts
  |> Enum.map(&Ecto.build_assoc(&1, :transaction, %{
    amount: Enum.random(-1000..1000), description: "Test tx #{10-i}", value_date: Ecto.DateTime.cast!(Timex.shift(Timex.now, days: -i))
  }))
  |> Enum.map(&Repo.insert!(&1))
end
