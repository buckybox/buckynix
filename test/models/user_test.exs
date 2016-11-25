defmodule Buckynix.UserTest do
  use Buckynix.ModelCase

  alias Buckynix.User

  @valid_attrs params_for(:user)

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, %{})
    refute changeset.valid?
  end
end
