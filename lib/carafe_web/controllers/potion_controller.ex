defmodule CarafeWeb.PotionController do
  use CarafeWeb, :controller

  alias Carafe.Potions
  alias Carafe.Accounts
  alias Carafe.Review
  alias Carafe.Vendors

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

  def vendors(conn, %{"first" => first, "last" => last}) do
    range = String.to_integer(first)..String.to_integer(last)
    cursor = :erlang.term_to_binary(range) |> Base.encode64()

    conn
    |> redirect(to: Routes.potion_path(conn, :vendors, cursor: cursor))
  end

  def vendors(conn, %{"cursor" => c}) do
    cursor_bin = Base.decode64!(c)
    cursor = Plug.Crypto.non_executable_binary_to_term(cursor_bin, [:safe])

    cursor_list = Enum.to_list(cursor)
    first = Enum.min(cursor_list)
    last = Enum.max(cursor_list)

    vendors = Vendors.get_vendors()
    rv = Enum.slice(vendors, first..last)
    render(conn, "vendors.html", vendors: rv, first: first, last: last)
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
