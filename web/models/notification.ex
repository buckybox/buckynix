defmodule Buckynix.Notification do
  use Buckynix.Web, :model

  schema "notifications" do
    field :body, :string
    belongs_to :user, Buckynix.User, type: :binary_id

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body])
    |> validate_required([:body])
  end
end
