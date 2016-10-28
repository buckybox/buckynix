defmodule Buckynix.Customer do
  use Buckynix.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "customers" do
    field :name, :string
    field :email, :string
    field :number, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :number])
    |> validate_required([:name, :email, :number])
  end
end
