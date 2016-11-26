defmodule Buckynix.Factory do
  use ExMachina.Ecto, repo: Buckynix.Repo

  def organization_factory do
    %Buckynix.Organization{
      name: Faker.Company.name,
      address: build(:address)
    }
  end

  def user_factory do
    %Buckynix.User{
      name: Faker.Name.name,
      email: sequence(:email, &"user#{&1}@example.net"),
      password_hash: Comeonin.Bcrypt.hashpwsalt("rubbish"),
      password: "rubbish",
      password_confirmation: "rubbish",
      phone: Enum.random([nil, Faker.Phone.EnGb.number]),
      tags: Enum.take_random(~w(test baller elixir), Enum.random(0..3)),
      account: build(:account)
    }
  end

  def account_factory do
    %Buckynix.Account{
      currency: "EUR"
    }
  end

  def transaction_factory do
    %Buckynix.Transaction{
      amount: Enum.random(-1000..1000),
      description: "Pay for #{Faker.Commerce.product_name}",
      value_date: Ecto.DateTime.cast!(Timex.shift(Timex.now, days: Enum.random(-30..0)))
    }
  end

  def address_factory do
    %Buckynix.Address{
      street: Faker.Address.street_address,
      state: Enum.random([nil, Faker.Address.state]),
      zip: Enum.random([nil, Faker.Address.zip]),
      city: Faker.Address.city
    }
  end

  def delivery_factory do
    %Buckynix.Delivery{
      date: Ecto.DateTime.cast!(Timex.shift(Timex.now, days: Enum.random(-30..30)))
    }
  end

  def notification_factory do
    %Buckynix.Notification{
      body: "This is a test notification to #{Faker.Company.bs}"
    }
  end
end
