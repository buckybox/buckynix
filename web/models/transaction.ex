defmodule Buckynix.Transaction do
  use Buckynix.Web, :model

  schema "transactions" do
    field :amount, Money.Ecto.Type
    field :description, :string
    field :value_date, Ecto.DateTime
    belongs_to :account, Buckynix.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:amount, :description, :value_date])
    |> validate_required([:amount, :description, :value_date])
  end
end
