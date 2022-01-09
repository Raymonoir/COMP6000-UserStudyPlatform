defmodule Comp6000Web.PageControllerTest do
  use Comp6000Web.ConnCase, async: true

  test "GET /app/*any", %{conn: conn} do
    conn = get(conn, "/app/*any")
    assert html_response(conn, 200) =~ "<div id=\"root\"></div>"
  end
end
