defmodule Comp6000.Plugs.SessionTest do
  use Comp6000Web.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, user} =
      Comp6000.Contexts.Users.create_user(%{
        username: "Ray123",
        email: "Ray123@email.com",
        password: "RaysPassword",
        firstname: "Raymond",
        lastname: "Ward"
      })

    conn =
      conn
      |> bypass_through(Comp6000Web.Router, :api)
      |> get("/api/users/loggedin")

    {:ok, %{conn: conn, user: user}}
  end

  describe "call/2" do
    test "no username in the session sets current_participant to a uuid in session", %{conn: conn} do
      conn = get(conn, "/api/users/loggedin")

      uuid = get_session(conn, :current_participant)

      assert uuid != nil

      conn = get(conn, "/api/users/loggedin")

      assert uuid == get_session(conn, :current_participant)
      assert uuid == conn.assigns[:current_participant]
    end

    test "username in the session sets the current user in assigns to the user with provided username",
         %{
           conn: conn,
           user: user
         } do
      conn =
        conn
        |> put_session(:username, user.username)
        |> send_resp(:ok, "")

      conn = get(conn, "/api/users/loggedin")

      assert conn.assigns[:current_user] == user
      assert get_session(conn, :username) == user.username
    end
  end
end
