defmodule Buckynix.Repo.Migrations.CreateOrganizationUser do
  use Ecto.Migration

  def change do
    create table(:organizations_users) do
      add :organization_id, references(:organizations, on_delete: :nothing, type: :binary_id), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:organizations_users, [:organization_id])
    create index(:organizations_users, [:user_id])
    create unique_index(:organizations_users, [:organization_id, :user_id])

    alter table(:organizations_users) do
      # XXX: seeds.exs isn't setting timestamps for some reason so we do it here
      # http://stackoverflow.com/a/37539453
      modify :inserted_at, :datetime, default: fragment("NOW()")
      modify :updated_at, :datetime, default: fragment("NOW()")
    end
  end
end
