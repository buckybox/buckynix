defmodule Buckynix.Account do
  use Buckynix.Web, :model

  schema "accounts" do
    belongs_to :customer, Buckynix.Customer, type: :binary_id
    field :currency, :string
    field :balance, Money.Ecto.Type

    has_many :transaction, Buckynix.Transaction

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:currency, :balance])
    |> validate_required([:currency, :balance])
  end
end
