defmodule Comp6000.Contexts.UsersTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.Users
  alias Comp6000.Schemas.User

  # setup do
  # end

  test "create_user/1 creates user and appends to database" do
    assert {:ok, user} = Users.create_user(%{username: "Ray123", email: "Ray123@email.com"})
    assert user == Repo.get_by(User, username: "Ray123")
  end

  test "get_user_by/1 returns user with the associated params" do
    assert nil == Users.get_user_by(username: "Ray123")

    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray123@email.com", lastname: "Ward"})

    assert user == Users.get_user_by(username: "Ray123")
    assert user == Users.get_user_by(email: "Ray123@email.com")
    assert user == Users.get_user_by(lastname: "Ward")
  end

  test "list_all_users/0 lists all created users" do
    {:ok, user1} = Users.create_user(%{username: "Ray123", email: "Ray123@email.com"})
    {:ok, user2} = Users.create_user(%{username: "Mais123", email: "Mais123@email.com"})
    assert [user1, user2] == Users.get_all_users()
  end

  test "change_user/2 changes a user within the database" do
    {:ok, user} = Users.create_user(%{username: "Ray123", email: "Ray123@email.com"})
    assert {:ok, changed_user} = Users.change_user(user, %{username: "Ray1234"})
    assert nil == Users.get_user_by(username: "Ray123")
    assert changed_user == Users.get_user_by(username: "Ray1234")
    assert changed_user.email == "Ray123@email.com"
  end

  test "delete_user/1 deletes a user from the database" do
    {:ok, user} = Users.create_user(%{username: "Ray123", email: "Ray123@email.com"})
    assert user == Users.get_user_by(username: "Ray123")
    assert {:ok, _user} = Users.delete_user(user)
    refute user == Users.get_user_by(username: "Ray123")
    refute user == Users.get_user_by(username: "Ray123@email.com")
  end
end
