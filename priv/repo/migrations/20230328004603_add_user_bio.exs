defmodule Carafe.Repo.Migrations.AddUserBio do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :bio, :text
    end
  end
end
