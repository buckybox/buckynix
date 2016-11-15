defmodule Buckynix.AddressTest do
  use Buckynix.ModelCase

  alias Buckynix.Address

  @valid_attrs %{street: "1 My Street", city: "Wellington"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Address.changeset(%Address{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Address.changeset(%Address{}, @invalid_attrs)
    refute changeset.valid?
  end
end
