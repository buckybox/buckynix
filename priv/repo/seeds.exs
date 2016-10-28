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

alias Buckynix.{Repo, Customer}

[
  %{
    name: "John Doe",
    email: "john@example.net",
    number: 42,
    # password: "12345678"
  },
  %{
    name: "Bob Carrot",
    email: "bob@carrot.net",
    number: 666,
    # password: "12345678"
  },
]
|> Enum.map(&Customer.changeset(%Customer{}, &1))
|> Enum.each(&Repo.insert!(&1))

