defmodule Buckynix.DeliveryTest do
  use Buckynix.ModelCase

  alias Buckynix.Delivery

  @valid_attrs %{date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Delivery.changeset(%Delivery{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Delivery.changeset(%Delivery{}, @invalid_attrs)
    refute changeset.valid?
  end
end
