defmodule Buckynix.OrganizationUser do
  use Buckynix.Web, :model

  schema "organizations_users" do
    belongs_to :organization, Buckynix.Organization
    belongs_to :user, Buckynix.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
