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

alias Buckynix.{Repo, Organization, User, Notification}

organizations = [
    %{
      name: "Organic Carrots Consortium",
    },
    %{
      name: "Dudes in a Garage",
    },
    %{
      name: "Buck Baller Market",
    },
  ]
  |> Enum.map(&Organization.changeset(%Organization{}, &1))
  |> Enum.map(&Repo.insert!(&1))

users = for i <- 1..Enum.random(10..50) do
  name = Enum.random(~w(Alice Bob Charlie Buck)) <> " " <> Enum.random(~w(Smith Dupont Carrot Baller))
  tags = Enum.take_random(~w(test baller elixir), Enum.random(0..3))

  user = User.changeset(%User{}, %{
    name: "#{name} #{i}",
    email: "user#{i}@example.net",
    password: "rubbish",
    password_confirmation: "rubbish",
    tags: tags
  })
  |> Repo.insert!

  organizations = Enum.take_random(organizations, Enum.random(1..length(organizations)))

  user
  |> Repo.preload(:organizations)
  |> Ecto.Changeset.change()
  |> Ecto.Changeset.put_assoc(:organizations, organizations)
  |> Repo.update!

  user
end

accounts =
  users
  |> Enum.map(&Ecto.build_assoc(&1, :account, %{currency: "EUR"}))
  |> Enum.map(&Repo.insert!(&1))

for i <- Enum.random(2..4)..0 do
  accounts
  |> Enum.map(&Ecto.build_assoc(&1, :transaction, %{
    amount: Enum.random(-1000..1000), description: "Test tx #{10-i}", value_date: Ecto.DateTime.cast!(Timex.shift(Timex.now, days: -i))
  }))
  |> Enum.map(&Repo.insert!(&1))
end

for user <- users do
  [
    %{
      body: "This is a test notification."
    },
    %{
      body: "This is another notification."
    },
  ]
  |> Enum.map(&Notification.changeset(%Notification{}, &1))
  |> Enum.map(&Ecto.Changeset.put_assoc(&1, :user, user))
  |> Enum.map(&Repo.insert!(&1))
end
