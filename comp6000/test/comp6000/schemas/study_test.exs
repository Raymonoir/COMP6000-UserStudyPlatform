defmodule Comp6000.Schemas.StudyTest do
  use Comp6000.DataCase
  alias Comp6000.Schemas.Study

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

  describe "changeset/2" do
    test "valid creation params creates valid changeset" do
      changeset = Study.changeset(%Study{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.title == "My First Study"
      assert changeset.changes.username == "Ray123"
      assert changeset.changes.task_count == 1
    end

    test "valid update params creates valid changeset" do
      study = struct(Study, @valid_params)
      changeset = Study.changeset(study, @update_params)

      assert changeset.changes.title == "My Second Study"
      assert changeset.changes.task_count == 2

      assert changeset.data.username == "Ray123"
    end

    test "invalid creation params returns invalid changeset" do
      changeset = Study.changeset(%Study{}, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               title: ["should be at least 4 character(s)"],
               username: ["can't be blank"]
             }
    end

    test "invalid update params returns invalid changeset" do
      study = struct(Study, @valid_params)
      changeset = Study.changeset(study, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{title: ["should be at least 4 character(s)"]}
    end
  end
end
