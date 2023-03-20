defmodule Carafe.Repo.Migrations.AddPotions do
  use Ecto.Migration

  def change do
    create table(:potions) do
      add :name, :string
      add :milliliters, :integer
      add :price, :integer
      add :secret, :boolean

      timestamps()
    end
  end
end
