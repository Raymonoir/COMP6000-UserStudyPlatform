defmodule Comp6000.Schemas.TaskTest do
  use Comp6000.DataCase
  alias Comp6000.Schemas.Task

  @valid_params %{
    content: "Your task is to pass this test",
    task_number: 4,
    study_id: 1
  }

  @update_params %{
    content: "Nope I mean pass ALL the tests",
    task_number: 2
  }

  @invalid_params %{
    content: nil
  }

  describe "changeset/2" do
    test "valid creation params creates valid changeset" do
      changeset = Task.changeset(%Task{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.content == "Your task is to pass this test"
      assert changeset.changes.task_number == 4
      assert changeset.changes.study_id == 1
    end

    test "valid update params creates valid changeset" do
      task = struct(Task, @valid_params)
      changeset = Task.changeset(task, @update_params)

      assert changeset.changes.content == "Nope I mean pass ALL the tests"
      assert changeset.changes.task_number == 2

      assert changeset.data.study_id == 1
    end

    test "invalid creation params returns invalid changeset" do
      changeset = Task.changeset(%Task{}, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{
               content: ["can't be blank"],
               study_id: ["can't be blank"],
               task_number: ["can't be blank"]
             }
    end

    test "invalid update params returns invalid changeset" do
      task = struct(Task, @valid_params)
      changeset = Task.changeset(task, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{content: ["can't be blank"]}
    end
  end
end
