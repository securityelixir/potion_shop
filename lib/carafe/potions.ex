defmodule Carafe.Potions do
  alias Carafe.Repo
  alias Carafe.Potion
  alias Carafe.Review

  import Ecto.Query

  def get_potion(id) do
    Repo.get(Potion, id)
    |> Repo.preload(:reviews)
  end

  def search_potions(name) do
    q = """
    SELECT p.id, p.name, p.milliliters, p.price, p.secret
    FROM potions as p
    WHERE p.name LIKE '%#{name}%' AND p.secret = false
    """

    {:ok, %{rows: rows}} =
      Ecto.Adapters.SQL.query(Repo, q)

    Enum.map(rows, fn row ->
      [id, name, milliliters, price, secret] = row
      %Potion{id: id, name: name, milliliters: milliliters, price: price, secret: secret}
    end)
  end

  def list_potions() do
    from(p in Potion,
      where: p.secret == false
    )
    |> Repo.all()
  end

  def get_reviews(potion_id) do
    from(r in Review,
      where: r.potion_id == ^potion_id
    )
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def api() do
    q = from(Potion, order_by: [asc: :id])
    Repo.paginate(q, cursor_fields: [:inserted_at, :id], limit: 2)
  end

  def api(a) do
    q = from(Potion, order_by: [asc: :id])
    Repo.paginate(q, after: a, cursor_fields: [:inserted_at, :id], limit: 2)
  end

  def create_potion(params) do
    %Potion{}
    |> Potion.changeset(params)
    |> Repo.insert()
  end

  def create_review(user_id, params) do
    %Review{}
    |> Review.changeset(params, user_id: user_id)
    |> Repo.insert()
  end
end
