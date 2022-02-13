defmodule Comp6000Web.UserControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.Users

  setup do
    Users.create_user(%{
      username: "Ray123",
      email: "Ray123@email.com",
      password: "RaysPassword",
      firstname: "Raymond",
      lastname: "Ward"
    })

    :ok
  end

  @creation_params %{
    username: "Mais123",
    email: "Mais123@email.com",
    password: "MaisPassword",
    firstname: "Maisie",
    lastname: "Lovett"
  }

  @invalid_creation_params %{
    username: "a",
    email: "noAtSign",
    password: "tooShort"
  }

  describe "POST /api/users/login" do
    test "login route returns correct json and logs user in if correct username and correct password provided",
         %{
           conn: conn
         } do
      conn = post(conn, "/api/users/login", %{username: "Ray123", password: "RaysPassword"})

      assert json_response(conn, 200) == %{"login" => true}
      assert get_session(conn, :username) == "Ray123"
    end

    test "login route returns correct json and does not log user in if correct username and incorrect password provided",
         %{
           conn: conn
         } do
      conn = post(conn, "/api/users/login", %{username: "Ray123", password: "RaysWrongPassword"})

      assert json_response(conn, 200) == %{"login" => false}
      refute get_session(conn, :username) == "Ray123"
    end

    test "login route returns correct json and does not log user in if incorrect username and correct password provided",
         %{
           conn: conn
         } do
      conn = post(conn, "/api/users/login", %{username: "RayWrong123", password: "RaysPassword"})

      assert json_response(conn, 200) == %{"login" => false}
      refute get_session(conn, :username) == "Ray123"
    end

    test "login route returns correct json and does not log user in if incorrect username and incorrect password provided",
         %{
           conn: conn
         } do
      conn =
        post(conn, "/api/users/login", %{username: "RayWrong123", password: "RaysWrongPassword"})

      assert json_response(conn, 200) == %{"login" => false}
      refute get_session(conn, :username) == "Ray123"
    end

    test "login route returns correct json and does not log user in if no username and no password provided",
         %{
           conn: conn
         } do
      conn = post(conn, "/api/users/login", %{})
      assert json_response(conn, 200) == %{"login" => false}
      refute get_session(conn, :username) == "Ray123"
    end
  end

  describe "POST /api/users/create" do
    test "create route returns correct json and creates user when valid paramaters provided", %{
      conn: conn
    } do
      conn = post(conn, "/api/users/create", @creation_params)
      assert json_response(conn, 200) == %{"created" => @creation_params.username}

      user = Users.get_user_by(username: @creation_params.username)

      assert user.email == @creation_params.email
      assert user.firstname == @creation_params.firstname
      assert user.lastname == @creation_params.lastname
    end

    test "create route returns correct json and does not create user when invalid paramaters provided",
         %{
           conn: conn
         } do
      conn = post(conn, "/api/users/create", @invalid_creation_params)

      assert json_response(conn, 200) == %{
               "error" =>
                 "email has invalid format,password should be at least 10 character(s),username should be at least 4 character(s)"
             }

      assert nil == Users.get_user_by(username: @invalid_creation_params.username)
    end
  end

  describe "GET /api/users/loggedin" do
    test "returns correct json when a user is logged in", %{conn: conn} do
      conn = post(conn, "/api/users/login", %{username: "Ray123", password: "RaysPassword"})

      assert json_response(conn, 200) == %{"login" => true}
      assert get_session(conn, :username) == "Ray123"

      conn = get(conn, "/api/users/loggedin")
      assert json_response(conn, 200) == %{"loggedIn" => true}
    end

    test "returns correct json when a user is not logged in", %{conn: conn} do
      conn = get(conn, "/api/users/loggedin")
      assert json_response(conn, 200) == %{"loggedIn" => false}
    end
  end

  describe "GET /api/users/logout" do
    test "returns correct json when a user is logged in", %{conn: conn} do
      conn = post(conn, "/api/users/login", %{username: "Ray123", password: "RaysPassword"})
      assert json_response(conn, 200) == %{"login" => true}
      assert get_session(conn, :username) == "Ray123"

      conn = get(conn, "/api/users/logout", %{})
      assert json_response(conn, 200) == %{"login" => false}
    end

    test "returns correct json when a user is not logged in", %{conn: conn} do
      conn = get(conn, "/api/users/logout", %{})
      assert json_response(conn, 200) == %{"login" => false}
      refute get_session(conn, :username) == "Ray123"
    end
  end

  describe "POST /api/users/edit" do
    test "valid parameters edits a user", %{conn: conn} do
      conn =
        post(conn, "/api/users/edit", %{
          username: "Ray123",
          email: "Jonny"
        })

      assert json_response(conn, 200) == %{"error" => "email has invalid format"}
      refute Users.get_user_by(username: "Ray123").email == "Jonny"
    end

    test "invalid parameters does not edit a user", %{conn: conn} do
      conn =
        post(conn, "/api/users/edit", %{
          username: "Ray123",
          firstname: "Jonny"
        })

      assert json_response(conn, 200) == %{"updated_user" => "Ray123"}
      assert Users.get_user_by(username: "Ray123").firstname == "Jonny"
    end
  end

  describe "POST /api/users/delete" do
    test "valid parameters deletes a user", %{conn: conn} do
      conn = post(conn, "/api/users/delete", %{username: "Ray123"})
      assert json_response(conn, 200) == %{"deleted_user" => "Ray123"}
      refute Users.get_user_by(username: "Ray123")
    end
  end
end
