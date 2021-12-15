defmodule Comp6000.Contexts.UsersTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.Users
  alias Comp6000.Schemas.User

  describe "User context" do
    @valid_user_params1 %{
      username: "Ray123",
      email: "Ray123@email.com",
      password: "RaysPassword",
      firstname: "Ray",
      lastname: "Ward"
    }
    @valid_user_params2 %{
      username: "Mais123",
      email: "Mais123@email.com",
      password: "MaisiesPassword",
      firstname: "Maisie",
      lastname: "Lovett"
    }

    test "create_user/1 creates user and appends to database" do
      {:ok, user} = Users.create_user(@valid_user_params1)
      assert user == Repo.get_by(User, username: @valid_user_params1[:username])
    end

    test "get_user_by/1 returns user with the associated params" do
      assert nil == Users.get_user_by(username: @valid_user_params1[:username])

      {:ok, user} = Users.create_user(@valid_user_params1)

      assert user == Users.get_user_by(username: @valid_user_params1[:username])
      assert user == Users.get_user_by(email: @valid_user_params1[:email])
      assert user == Users.get_user_by(lastname: @valid_user_params1[:lastname])
    end

    test "list_all_users/0 lists all created users" do
      {:ok, user1} = Users.create_user(@valid_user_params1)
      {:ok, user2} = Users.create_user(@valid_user_params2)
      assert [user1, user2] == Users.get_all_users()
    end

    test "change_user/2 changes a user within the database" do
      {:ok, user} = Users.create_user(@valid_user_params1)
      assert {:ok, changed_user} = Users.update_user(user, %{username: "Ray1234"})
      assert nil == Users.get_user_by(username: @valid_user_params1[:username])
      assert changed_user == Users.get_user_by(username: "Ray1234")
      assert changed_user.email == @valid_user_params1[:email]
    end

    test "delete_user/1 deletes a user from the database" do
      {:ok, user} = Users.create_user(@valid_user_params1)
      assert user == Users.get_user_by(username: @valid_user_params1[:username])
      {:ok, _user} = Users.delete_user(user)
      refute user == Users.get_user_by(username: @valid_user_params1[:username])
      refute user == Users.get_user_by(email: @valid_user_params1[:email])
    end
  end
end
