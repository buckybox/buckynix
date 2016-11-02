defmodule Buckynix.Transaction do
  use Buckynix.Web, :model

  schema "transactions" do
    field :amount, Money.Ecto.Type
    field :description, :string
    field :value_date, Ecto.DateTime
    belongs_to :account, Buckynix.Account

    field :balance, Money.Ecto.Type, virtual: true

    timestamps
  end

  @required_fields ~w(amount description value_date)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
