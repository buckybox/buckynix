defmodule Buckynix.Customer do
  use Buckynix.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "customers" do
    field :name, :string
    field :email, :string

    has_one :account, Buckynix.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:name, :email])
  end
end
