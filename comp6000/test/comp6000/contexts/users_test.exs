defmodule Comp6000.Contexts.UsersTest do
  use Comp6000.DataCase, async: true

  alias Comp6000.Schemas.User
  alias Comp6000.Contexts.Users

  describe "users" do
    @valid_params %{
      username: "username1",
      firstname: "firstname1",
      lastname: "lastname1",
      email: "email1",
      password: "password1"
    }
    @update_params %{
      firstname: "firstname2",
      lastname: "lastname2"
    }

    @invalid_params %{
      firstname: "firstname1",
      lastname: "lastname1",
      password: "password1"
    }

    test "create_user/1 with valid params creates user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_params)
      assert user.username == "username1"
      assert user.firstname == "firstname1"
      assert user.lastname == "lastname1"
      assert user.email == "email1"
      assert user.password == "password1"
    end

    test "update_user/2 with valid params updates user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_params)
      assert {:ok, %User{} = user1} = Users.change_user(user, @update_params)

      refute user.firstname == "firstname2"
      refute user.lastname == "lastname2"

      assert user1.firstname == "firstname2"
      assert user1.lastname == "lastname2"
    end
  end
end
