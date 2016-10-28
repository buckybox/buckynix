defmodule Buckynix.CustomerTest do
  use Buckynix.ModelCase

  alias Buckynix.Customer

  @valid_attrs %{email: "joe#{Enum.random(1..100)}@test.local", name: "Joe", number: Enum.random(1..100)}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Customer.changeset(%Customer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Customer.changeset(%Customer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
