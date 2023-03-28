defmodule CarafeWeb.UserController do
  use CarafeWeb, :controller

  alias Carafe.Accounts

  def show(conn, %{"id" => id}) do
    %{bio: bio, email: email} = Accounts.get_user!(id)
    render(conn, "show.html", email: email, bio: bio)
  end
end
