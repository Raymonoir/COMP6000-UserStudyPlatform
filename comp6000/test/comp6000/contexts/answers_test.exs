defmodule Comp6000.Contexts.AnswersTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Studies, Users, Tasks, Answers}
  alias Comp6000.Schemas.Answer

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, task} =
      Tasks.create_task(%{content: "What is 2*2?", task_number: 1, study_id: study.id})

    valid_answer_params1 = %{
      task_id: task.id,
      content: "4"
    }

    invalid_answer_params = %{
      content: "I forgot task ID"
    }

    %{
      valid_answer_params1: valid_answer_params1,
      invalid_answer_params: invalid_answer_params
    }
  end

  describe "create_answer/1" do
    test "valid parameters creates answer and appends to database", %{
      valid_answer_params1: valid_answer_params1
    } do
      {:ok, answer} = Answers.create_answer(valid_answer_params1)
      assert answer == Repo.get_by(Answer, id: answer.id)
    end

    test "invalid parameters does not create answer and does not append to database", %{
      invalid_answer_params: invalid_answer_params
    } do
      {:error, _changeset} = Answers.create_answer(invalid_answer_params)
      refute Repo.get_by(Answer, content: invalid_answer_params[:content])
    end
  end

  describe "change_answer/2" do
    test "valid parameters changes answer within the database", %{
      valid_answer_params1: valid_answer_params1
    } do
      {:ok, answer} = Answers.create_answer(valid_answer_params1)
      assert {:ok, changed_answer} = Answers.update_answer(answer, %{content: "Updated Content"})
      assert nil == Answers.get_answer_by(content: valid_answer_params1[:content])
      assert changed_answer == Answers.get_answer_by(content: "Updated Content")
      assert changed_answer.task_id == valid_answer_params1[:task_id]
    end

    test "invalid parameters does not change an answer within the database", %{
      valid_answer_params1: valid_answer_params1
    } do
      {:ok, answer} = Answers.create_answer(valid_answer_params1)
      assert {:error, _changeset} = Answers.update_answer(answer, %{content: ""})
      assert nil == Answers.get_answer_by(content: "")

      assert answer ==
               Answers.get_answer_by(content: valid_answer_params1[:content])
    end
  end

  test "get_answer_by/1 returns answer with the associated params", %{
    valid_answer_params1: valid_answer_params1
  } do
    assert nil == Answers.get_answer_by(content: valid_answer_params1[:content])

    {:ok, answer} = Answers.create_answer(valid_answer_params1)

    assert answer == Answers.get_answer_by(content: valid_answer_params1[:content])

    assert answer == Answers.get_answer_by(task_id: valid_answer_params1[:task_id])
  end

  test "delete_answer/1 deletes an answer from the database", %{
    valid_answer_params1: valid_answer_params1
  } do
    {:ok, answer} = Answers.create_answer(valid_answer_params1)

    assert answer ==
             Answers.get_answer_by(content: valid_answer_params1[:content])

    {:ok, _answer} = Answers.delete_answer(answer)
    refute answer == Answers.get_answer_by(content: valid_answer_params1[:content])
    refute answer == Answers.get_answer_by(task_id: valid_answer_params1[:task_id])
  end
end
