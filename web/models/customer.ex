defmodule Buckynix.Customer do
  use Buckynix.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "customers" do
    field :name, :string
    field :email, :string
    field :tags, {:array, :string}

    field :url, :string, virtual: true

    has_one :account, Buckynix.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :tags])
    |> validate_required([:name, :email, :tags])
  end
end
