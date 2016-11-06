defmodule Buckynix.UserTest do
  use Buckynix.ModelCase

  alias Buckynix.User

  @valid_attrs %{email: "joe#{Enum.random(1..100)}@test.local", name: "Joe", number: Enum.random(1..100)}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
