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

alias Buckynix.{Repo}

import Buckynix.Factory

organization_addresses = insert_list(3, :address)
organization_names = [
  "Organic Carrots Consortium",
  "Dudes in a Garage",
  "Buck Baller Market",
]

organizations = for {name, address} <- Enum.zip(organization_names, organization_addresses) do
  insert(:organization, %{name: name, address: address})
end

users = insert_list(Enum.random(10..50), :user)

addresses = insert_list(30, :address)
users_with_address = Enum.take_random(users, 30)

for {user, address} <- Enum.zip(users_with_address, addresses) do
  user
  |> Repo.preload(:address)
  |> Ecto.Changeset.change
  |> Ecto.Changeset.put_assoc(:address, address)
  |> Repo.update!
end

for user <- users do
  organizations = Enum.take_random(organizations, Enum.random(1..length(organizations)))

  user
  |> Repo.preload(:organizations)
  |> Ecto.Changeset.change
  |> Ecto.Changeset.put_assoc(:organizations, organizations)
  |> Repo.update!
end

for account <- Repo.all(Buckynix.Account) do
  insert_list(Enum.random(0..5), :transaction, account: account)
end

for user <- users do
  insert(:notification, user: user)
end

now = Timex.now
dates = Enum.map(-20..8, fn(delta) -> Timex.shift(now, days: delta) end)
users = users |> Repo.preload(:address)

for user <- users do
  dates
  |> Enum.filter(fn(date) -> rem(Timex.day(date), 7) != 0 end)
  |> Enum.filter(fn(_) -> Enum.random([true, false]) end)
  |> Enum.map(&Buckynix.Delivery.changeset(%Buckynix.Delivery{}, %{date: &1}))
  |> Enum.map(&Ecto.Changeset.put_assoc(&1, :user, user))
  |> Enum.map(&Ecto.Changeset.put_embed(&1, :address, user.address)) # FIXME nil
  |> Enum.map(&Repo.insert!(&1))
end
