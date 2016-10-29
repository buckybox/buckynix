defmodule Buckynix.TransactionTest do
  use Buckynix.ModelCase

  alias Buckynix.Transaction

  @valid_attrs %{amount: 42, description: "some content", value_date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Transaction.changeset(%Transaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
