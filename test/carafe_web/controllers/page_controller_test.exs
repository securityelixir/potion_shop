defmodule CarafeWeb.PotionControllerTest do
  use CarafeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Potion Shop"
  end
end
