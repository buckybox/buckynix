defmodule Buckynix.User do
  use Buckynix.Web, :model
  use Coherence.Schema

  schema "users" do
    coherence_schema
    field :name, :string
    field :email, :string
    field :tags, {:array, :string}, default: []

    field :archived_at, Ecto.DateTime

    has_one :account, Buckynix.Account
    belongs_to :address, Buckynix.Address
    has_many :notifications, Buckynix.Notification
    many_to_many :organizations, Buckynix.Organization, join_through: "organizations_users"

    timestamps

    field :url, :string, virtual: true
    field :balance, :string, virtual: true
  end

  @required_fields ~w(name email tags)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ coherence_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def non_archived(query) do
    from u in query, where: is_nil(u.archived_at)
  end

  def with_tag(query, tag) do
    case tag do
      nil -> from u in query
      _ ->   from u in query,
             where: fragment("? = ANY(tags)", ^tag)
    end
  end
end
