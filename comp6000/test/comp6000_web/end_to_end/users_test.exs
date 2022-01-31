defmodule Comp6000Web.EndToEnd.UsersTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.Users

  # Change these tests, as currently they are very similar to users_controller
  # Maybe do practise runs ie logged out user, then logs in, then checks logged in etc
  describe "/users/create route" do
    test "Creating a user and retrieving the created user from the database", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), %{
          username: "James123",
          password: "JamesPass321",
          email: "James@email.com"
        })

      assert json_response(conn, 200) == %{"created" => "James123"}

      user = Users.get_user_by(username: "James123")

      assert user
      assert user.username == "James123"
      assert user.email == "James@email.com"
    end

    test "Creating a user with inavlid parameters and attempting to retrieve the created user from the database",
         %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), %{
          username: "James123",
          password: "tooShort",
          email: "NoAtSign"
        })

      assert json_response(conn, 200) == %{
               "error" => "email has invalid format,password should be at least 10 character(s)"
             }

      refute Users.get_user_by(username: "James123")
    end
  end
end
