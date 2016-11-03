defmodule Buckynix.Organization do
  use Buckynix.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "organizations" do
    field :name, :string

    many_to_many :users, Buckynix.User, join_through: "organizations_users"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
