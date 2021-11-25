defmodule Comp6000Web.AuthenticationTest do
  use Comp6000.DataCase
  alias Comp6000Web.Authentication

  setup do
    Comp6000.Contexts.Users.create_user(%{
      username: "Ray123",
      email: "Ray123@email.com",
      password: "RaysPassword",
      firstname: "Raymond",
      lastname: "Ward"
    })

    :ok
  end

  describe "login/2" do
    test "valid username and valid password returns true" do
      assert {true, _user} = Authentication.login("Ray123", "RaysPassword")
    end

    test "valid username and invalid password returns false" do
      assert {false, _user} = Authentication.login("Ray123", "WrongPassword")
    end

    test "invalid username and valid password returns false" do
      assert {false, _user} = Authentication.login("WrongUsername", "RaysPassword")
    end

    test "invalid username and invalid password returns false" do
      assert {false, _user} = Authentication.login("WrongUsername", "WrongPassword")
    end
  end
end
