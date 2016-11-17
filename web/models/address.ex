defmodule Buckynix.Address do
  use Buckynix.Web, :model

  schema "addresses" do
    field :street, :string
    field :zip, :string
    field :state, :string
    field :city, :string

    timestamps
  end

  @required_fields ~w(street city)a
  @optional_fields ~w(state zip)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
