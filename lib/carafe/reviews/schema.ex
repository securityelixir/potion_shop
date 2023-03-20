defmodule Carafe.Review do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:body, :score, :user_id, :potion_id]

  schema "reviews" do
    field :body, :string
    field :score, :integer

    belongs_to :user, Carafe.Accounts.User
    belongs_to :potion, Carafe.Potion

    timestamps()
  end

  def changeset(review, attrs \\ %{}) do
    review
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_number(:score, greater_than: 0, less_than: 6)
  end
end
