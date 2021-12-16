defmodule Comp6000.Schemas.AnswerTest do
  use Comp6000.DataCase
  alias Comp6000.Schemas.Answer

  @valid_params %{
    content: "The answer should be 21",
    task_id: 1
  }

  @update_params %{
    content: "Ahh I can't add, the answer should be 22"
  }

  @invalid_params %{
    task_id: nil
  }

  describe "changeset/2" do
    test "valid creation params creates valid changeset" do
      changeset = Answer.changeset(%Answer{}, @valid_params)
      assert changeset.valid?
      assert changeset.changes.content == "The answer should be 21"
      assert changeset.changes.task_id == 1
    end

    test "valid update params creates valid changeset" do
      task = struct(Answer, @valid_params)
      changeset = Answer.changeset(task, @update_params)

      assert changeset.changes.content == "Ahh I can't add, the answer should be 22"

      assert changeset.data.task_id == 1
    end

    test "invalid creation params returns invalid changeset" do
      changeset = Answer.changeset(%Answer{}, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{content: ["can't be blank"], task_id: ["can't be blank"]}
    end

    test "invalid update params returns invalid changeset" do
      answer = struct(Answer, @valid_params)
      changeset = Answer.changeset(answer, @invalid_params)
      refute changeset.valid?

      assert errors_on(changeset) == %{task_id: ["can't be blank"]}
    end
  end
end
