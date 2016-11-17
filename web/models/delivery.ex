defmodule Buckynix.Delivery do
  use Buckynix.Web, :model

  schema "deliveries" do
    field :date, Ecto.DateTime
    field :status, :string, default: "open"

    belongs_to :user, Buckynix.User
    embeds_one :archived_address, Buckynix.Address

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date])
    |> validate_required([:date])
    |> update_status
  end

  def update_status(changeset) do
    # FIXME: or PGSQL TRIGGER?
    if changeset.changes[:status] == :deliverd do
      changeset |> put_assoc(:address, changeset.data.user.address)
    else
      changeset
    end
  end
end
