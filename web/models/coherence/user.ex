defmodule Buckynix.User do
  use Buckynix.Web, :model
  use Coherence.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    coherence_schema
    field :name, :string
    field :email, :string
    field :tags, {:array, :string}, default: []
    timestamps

    field :url, :string, virtual: true
    field :balance, :string, virtual: true

    has_one :account, Buckynix.Account
    has_many :notifications, Buckynix.Notification
    many_to_many :organizations, Buckynix.Organization, join_through: "organizations_users"
  end

  @required_fields ~w(name email tags)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ coherence_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def with_tag(query, tag) do
    case tag do
      nil -> from c in query
      _ ->   from c in query,
             where: fragment("? = ANY(tags)", ^tag)
    end
  end
end
