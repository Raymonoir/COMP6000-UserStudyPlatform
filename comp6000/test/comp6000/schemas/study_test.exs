defmodule Comp6000.Schemas.StudyTest do
  use Comp6000.DataCase
  alias Comp6000.Schemas.Study

  describe "study" do
    @valid_params %{
      title: "My First Study",
      username: "Ray123",
      task_count: 1
    }

    @update_params %{
      title: "My Second Study",
      task_count: 2
    }

    @invalid_params %{
      title: "1",
      task_count: 3
    }

    test "changeset/2 with valid params creates study" do
      changeset = Study.changeset(%Study{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.title == "My First Study"
      assert changeset.changes.username == "Ray123"
      assert changeset.changes.task_count == 1
    end

    test "changeset/2 with valid params updates study" do
      user = struct(Study, @valid_params)
      changeset = Study.changeset(user, @update_params)

      refute changeset.changes.title == "My First Study"
      assert changeset.changes.title == "My Second Study"
      assert changeset.changes.task_count == 2

      assert changeset.data.username == "Ray123"
    end

    test "changset/2 with invalid params returns invalid changeset" do
      changeset = Study.changeset(%Study{}, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               title: ["should be at least 4 character(s)"],
               username: ["can't be blank"]
             }
    end
  end
end
