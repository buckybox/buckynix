defmodule Buckynix.Customer do
  use Buckynix.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "customers" do
    field :name, :string
    field :email, :string
    field :tags, {:array, :string}, default: []

    field :url, :string, virtual: true
    field :balance, :string, virtual: true

    has_one :account, Buckynix.Account

    timestamps
  end

  @required_fields ~w(name email tags)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

  def with_tag(query, tag) do
    case tag do
      nil -> from c in query
      _ ->   from c in query,
             where: fragment("? = ANY(tags)", ^tag)
    end
  end
end
