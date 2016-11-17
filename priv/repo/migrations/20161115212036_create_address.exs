defmodule Buckynix.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :street, :string
      add :zip, :string
      add :state, :string
      add :city, :string

      timestamps
    end

    alter table(:organizations) do
      add :address_id, references(:addresses, on_delete: :delete_all, type: :binary_id), null: false
    end

    create index(:organizations, [:address_id])

    alter table(:users) do
      add :address_id, references(:addresses, on_delete: :delete_all, type: :binary_id), null: true
    end

    create index(:users, [:address_id])
  end
end
