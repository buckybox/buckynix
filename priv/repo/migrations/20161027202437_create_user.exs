defmodule Buckynix.Repo.Migrations.CreateUser do
  use Ecto.Migration
  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :email, :string, null: false
      add :tags, {:array, :string}, null: false, default: []

      add :archived_at, :datetime, null: true, default: nil

      # rememberable
      add :remember_created_at, :datetime
      # trackable
      add :sign_in_count, :integer, default: 0
      add :current_sign_in_at, :datetime
      add :last_sign_in_at, :datetime
      add :current_sign_in_ip, :string
      add :last_sign_in_ip, :string
      # lockable
      add :failed_attempts, :integer, default: 0
      add :locked_at, :datetime
      # recoverable
      add :reset_password_token, :string
      add :reset_password_sent_at, :datetime
      # authenticatable
      add :password_hash, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, :id, where: "archived_at IS NULL")

    execute "
      CREATE TRIGGER users_delete
      BEFORE DELETE ON users
      FOR EACH ROW EXECUTE PROCEDURE never_delete();
    "
  end
end
