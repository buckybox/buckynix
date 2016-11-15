defmodule Buckynix.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      add :street, :string
      add :zip, :string
      add :state, :string
      add :city, :string

      timestamps
    end

    create index(:addresses, [:user_id])
  end
end
