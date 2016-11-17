defmodule Buckynix.Organization do
  use Buckynix.Web, :model

  schema "organizations" do
    field :name, :string

    belongs_to :address, Buckynix.Address
    many_to_many :users, Buckynix.User, join_through: "organizations_users"

    timestamps
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
