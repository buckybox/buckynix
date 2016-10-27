defmodule Buckynix.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :name, :string
      add :email, :string
      add :number, :integer

      timestamps()
    end

  end
end
