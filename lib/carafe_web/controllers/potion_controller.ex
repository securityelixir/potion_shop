defmodule CarafeWeb.PotionController do
  use CarafeWeb, :controller

  alias Carafe.Potions
  alias Carafe.Accounts
  alias Carafe.Review

  def index(conn, %{"name" => name}) do
    potions = Potions.search_potions(name)
    render(conn, "index.html", potions: potions)
  end

  def index(conn, _params) do
    potions = Potions.list_potions()
    render(conn, "index.html", potions: potions)
  end

  def show(conn, %{"id" => id}) do
    potion = Potions.get_potion(id)
    changeset = Review.changeset(%Review{})
    reviews = Potions.get_reviews(id)
    render(conn, "show.html", potion: potion, reviews: reviews, changeset: changeset)
  end

  def create_review(conn, %{"id" => potion_id, "review" => review_params}) do
    potion = Potions.get_potion(potion_id)
    user = Accounts.get_user_by_email(review_params["email"])

    params =
      review_params
      |> Map.put("user_id", user.id)
      |> Map.put("potion_id", potion_id)

    case Potions.create_review(params) do
      {:ok, _review} ->
        conn
        |> put_flash(:info, "Review created")
        |> redirect(to: Routes.potion_path(conn, :show, potion_id))

      {:error, changeset} ->
        render(conn, "show.html", potion: potion, changeset: changeset)
    end
  end

  def api(conn, %{"after" => a}) do
    %{entries: entries, metadata: m} = Potions.api(a)
    json(conn, %{potions: entries, after: m.after})
  end

  def api(conn, _params) do
    %{entries: entries, metadata: m} = Potions.api()
    json(conn, %{potions: entries, after: m.after})
  end
end
