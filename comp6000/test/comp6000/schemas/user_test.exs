defmodule Comp6000.Schemas.UserTest do
  use Comp6000.DataCase
  alias Comp6000.Schemas.User

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
    username: "ThisIsValid",
    email: "wrong_format.com",
    password: "too short",
    firstname: "valid_firstname",
    lastname: "valid_lastname"
  }

  describe "creation_changeset/2" do
    test "valid params creates valid changeset" do
      changeset = User.creation_changeset(%User{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.username == "Ray123"
      assert changeset.changes.email == "Ray123@email.com"
      assert changeset.changes.firstname == "Ray"
      assert changeset.changes.lastname == "Ward"
    end

    test "invalid params creates invalid changeset" do
      changeset = User.creation_changeset(%User{}, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               email: ["has invalid format"],
               password: ["should be at least 10 character(s)"]
             }
    end
  end

  describe "update_changeset/2" do
    test "valid params created valid changeset" do
      user = struct(User, @valid_params)
      changeset = User.update_changeset(user, @update_params)

      refute changeset.changes.username == "Ray123"

      assert changeset.changes.username == "new_username"
      assert changeset.changes.lastname == "new_lastname"

      assert changeset.data.email == "Ray123@email.com"
    end

    test "invalid params created invalid changeset" do
      user = struct(User, @valid_params)
      changeset = User.update_changeset(user, @invalid_params)

      refute changeset.valid?

      assert errors_on(changeset) == %{
               email: ["has invalid format"],
               password: ["should be at least 10 character(s)"]
             }
    end
  end
end
