defmodule Buckynix.OrganizationUserTest do
  use Buckynix.ModelCase

  alias Buckynix.OrganizationUser

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OrganizationUser.changeset(%OrganizationUser{}, @valid_attrs)
    assert changeset.valid?
  end

  # XXX: no possible invalid scenario for now
  # test "changeset with invalid attributes" do
  #   changeset = OrganizationUser.changeset(%OrganizationUser{}, @invalid_attrs)
  #   refute changeset.valid?
  # end
end
