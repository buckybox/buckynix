defmodule Buckynix.CustomerTest do
  use Buckynix.ModelCase

  alias Buckynix.Customer

  @valid_attrs %{email: "some content", name: "some content", number: 42}
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
