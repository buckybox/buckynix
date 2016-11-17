defmodule Buckynix.Repo.Migrations.CreateSharedFunctions do
  use Ecto.Migration

  def change do
    execute "
      CREATE OR REPLACE FUNCTION never_delete() RETURNS trigger AS $$
      BEGIN
        RAISE EXCEPTION 'DELETE forbidden';
      END;
      $$ LANGUAGE plpgsql;
    "
  end
end
