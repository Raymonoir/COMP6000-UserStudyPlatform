defmodule COmp6000Web.EndToEnd.UsersTest do
  use Comp6000Web.ConnCase
  alias Comp6000.Contexts.Users

  describe "Main functionality for the users routes" do
    test "Creating a user and retrieving the created user from the database", %{conn: conn} do
      conn =
        post(conn, Routes.users_path(conn, :create), %{
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
        post(conn, Routes.users_path(conn, :create), %{
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