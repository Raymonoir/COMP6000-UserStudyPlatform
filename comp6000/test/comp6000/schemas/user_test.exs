defmodule Comp6000.Schemas.UserTest do
  use Comp6000.DataCase
  alias Comp6000.Schemas.User

  describe "users" do
    @valid_params %{
      username: "username",
      firstname: "firstname",
      lastname: "lastname",
      email: "email",
      password: "password"
    }
    @update_params %{
      username: "new_username",
      lastname: "new_lastname"
    }

    @invalid_params %{
      username: nil,
      firstname: "invalid_firstname",
      lastname: "invalid_lastname",
      password: "invalid_password"
    }

    test "changeset/2 with valid params creates user" do
      changeset = User.changeset(%User{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.username == "username"
      assert changeset.changes.firstname == "firstname"
      assert changeset.changes.lastname == "lastname"
      assert changeset.changes.email == "email"
      assert changeset.changes.password == "password"
    end

    test "changeset/2 with valid params updates user" do
      user = %User{username: "Ray123", email: "Ray123@email.com"}
      changeset = User.changeset(user, @update_params)

      refute changeset.changes.username == "Ray123"
      assert changeset.changes.username == "new_username"
      assert changeset.changes.lastname == "new_lastname"

      assert changeset.data.email == "Ray123@email.com"
    end

    test "changeset/2 with invalid params returns invalid changeset" do
      changeset = User.changeset(%User{}, @invalid_params)
      refute changeset.valid?
      assert %{email: ["can't be blank"], username: ["can't be blank"]} == errors_on(changeset)
    end
  end
end
