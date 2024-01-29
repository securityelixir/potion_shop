defmodule CarafeWeb.UserSessionController do
  use CarafeWeb, :controller

  alias Carafe.Accounts
  alias CarafeWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params
    conn = assign(conn, :paraxial_login_user_name, email)

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn = assign(conn, :paraxial_login_success, true)
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn = assign(conn, :paraxial_login_success, false)
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
