defmodule Buckynix.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:customers, [:email])
  end
end
