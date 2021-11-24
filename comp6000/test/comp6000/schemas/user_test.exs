defmodule Comp6000.Schemas.UserTest do
  use Comp6000.DataCase
  alias Comp6000.Schemas.User

  describe "users" do
    @valid_params %{
      username: "Ray123",
      email: "Ray123@email.com",
      password: "RaysPassword",
      firstname: "Ray",
      lastname: "Ward"
    }
    @update_params %{
      username: "new_username",
      lastname: "new_lastname"
    }

    @invalid_params %{
      username: "123",
      email: "wrong_format.com",
      password: "too short",
      firstname: "invalid_firstname",
      lastname: "invalid_lastname"
    }

    test "changeset/2 with valid params creates user" do
      changeset = User.changeset(%User{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.username == "Ray123"
      assert changeset.changes.email == "Ray123@email.com"
      assert changeset.changes.firstname == "Ray"
      assert changeset.changes.lastname == "Ward"
    end

    test "changeset/2 with valid params updates user" do
      user = struct(User, @valid_params)
      changeset = User.changeset(user, @update_params)

      refute changeset.changes.username == "Ray123"
      assert changeset.changes.username == "new_username"
      assert changeset.changes.lastname == "new_lastname"

      assert changeset.data.email == "Ray123@email.com"
    end

    test "changeset/2 with invalid params returns invalid changeset" do
      changeset = User.changeset(%User{}, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               email: ["has invalid format"],
               username: ["should be at least 4 character(s)"],
               password: ["should be at least 10 character(s)"]
             }
    end
  end
end
