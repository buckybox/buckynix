defmodule Buckynix.User do
  use Buckynix.Web, :model
  use Coherence.Schema

  schema "users" do
    field :name, :string
    field :email, :string
    coherence_schema

    many_to_many :organizations, Buckynix.Organization, join_through: "organizations_users"
    has_many :notifications, Buckynix.Notification

    timestamps
  end

  @required_fields ~w(name email)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ coherence_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end
end
