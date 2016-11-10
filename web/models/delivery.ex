defmodule Buckynix.Delivery do
  use Buckynix.Web, :model

  schema "deliveries" do
    field :date, Ecto.DateTime
    belongs_to :user, Buckynix.User, type: :binary_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date])
    |> validate_required([:date])
  end
end
