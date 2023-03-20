defmodule Carafe.Repo.Migrations.AddReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :body, :text
      add :score, :integer
      add :user_id, references(:users)
      add :potion_id, references(:potions)

      timestamps()
    end
  end
end
