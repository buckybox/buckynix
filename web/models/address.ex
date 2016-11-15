defmodule Buckynix.Address do
  use Buckynix.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "addresses" do
    field :street, :string
    field :zip, :string
    field :state, :string
    field :city, :string
    belongs_to :user, Buckynix.User, type: :binary_id

    timestamps()
  end

  @required_fields ~w(street city)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
