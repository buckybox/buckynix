defmodule Buckynix.Repo.Migrations.CreateDelivery do
  use Ecto.Migration

  def change do
    create table(:deliveries) do
      add :date, :datetime, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps
    end

    create index(:deliveries, [:user_id])
  end
end