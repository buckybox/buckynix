defmodule Buckynix.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :customer_id, references(:customers, on_delete: :delete_all, type: :binary_id)
      add :currency, :string
      add :balance, :integer

      timestamps()
    end

    create index(:accounts, [:customer_id])
  end
end
