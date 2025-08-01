defmodule Carafe.Potion do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :milliliters, :price, :secret]}
  schema "potions" do
    field :name, :string
    field :milliliters, :integer
    field :price, :integer
    field :secret, :boolean

    has_many :reviews, Carafe.Review

    timestamps()
  end

  def changeset(potion, attrs \\ %{}) do
    potion
    |> cast(attrs, [:name, :milliliters, :price, :secret])
    |> validate_required([:name, :milliliters, :price, :secret])
  end
end
