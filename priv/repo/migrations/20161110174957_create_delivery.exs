defmodule Buckynix.Repo.Migrations.CreateDelivery do
  use Ecto.Migration

  def change do
    execute("CREATE TYPE delivery_status AS ENUM ('open', 'pending', 'delivered')")

    create table(:deliveries, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :date, :datetime, null: false
      add :status, :delivery_status, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      add :archived_address, :map, null: true, default: nil

      timestamps
    end

    create index(:deliveries, [:user_id])
  end
end
