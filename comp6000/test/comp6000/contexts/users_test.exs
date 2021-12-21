defmodule Comp6000.Contexts.UsersTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.Users
  alias Comp6000.Schemas.User

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

  @invalid_user_params %{
    username: "no",
    email: "No at sign",
    password: "tooSmol",
    firstname: "McInvalid",
    lastname: "Invalidson"
  }

  describe "create_user/1" do
    test "valid parameters creates user and appends to database" do
      {:ok, user} = Users.create_user(@valid_user_params1)
      assert user == Repo.get_by(User, username: @valid_user_params1[:username])
    end

    test "invalid parameters does not create user and does not append to database" do
      {:error, _changeset} = Users.create_user(@invalid_user_params)
      refute Repo.get_by(User, username: @invalid_user_params[:username])
    end
  end

  describe "change_user/2" do
    test "valid parameters changes a user within the database" do
      {:ok, user} = Users.create_user(@valid_user_params1)
      assert {:ok, changed_user} = Users.update_user(user, %{username: "Ray1234"})
      assert nil == Users.get_user_by(username: @valid_user_params1[:username])
      assert changed_user == Users.get_user_by(username: "Ray1234")
      assert changed_user.email == @valid_user_params1[:email]
    end

    test "invalid parameters does not change a user within the database" do
      {:ok, user} = Users.create_user(@valid_user_params1)
      assert {:error, _changeset} = Users.update_user(user, %{username: "123"})
      assert nil == Users.get_user_by(username: "123")
      assert user == Users.get_user_by(username: @valid_user_params1[:username])
    end
  end

  test "get_user_by/1 returns user with the associated params" do
    assert nil == Users.get_user_by(username: @valid_user_params1[:username])

    {:ok, user} = Users.create_user(@valid_user_params1)

    assert user == Users.get_user_by(username: @valid_user_params1[:username])
    assert user == Users.get_user_by(email: @valid_user_params1[:email])
    assert user == Users.get_user_by(lastname: @valid_user_params1[:lastname])
  end

  test "list_all_users/0 lists all created users" do
    assert [] == Users.get_all_users()
    {:ok, user1} = Users.create_user(@valid_user_params1)
    {:ok, user2} = Users.create_user(@valid_user_params2)
    assert [user1, user2] == Users.get_all_users()
  end

  test "delete_user/1 deletes a user from the database" do
    {:ok, user} = Users.create_user(@valid_user_params1)
    assert user == Users.get_user_by(username: @valid_user_params1[:username])
    {:ok, _user} = Users.delete_user(user)
    refute user == Users.get_user_by(username: @valid_user_params1[:username])
    refute user == Users.get_user_by(email: @valid_user_params1[:email])
  end
end
