defmodule Comp6000.Contexts.TasksTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Studies, Users, Tasks}
  alias Comp6000.Schemas.Task

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    valid_task_params1 = %{
      task_number: 1,
      content: "What is 2*2?",
      study_id: study.id
    }

    invalid_task_params = %{
      content: "I forgot the task number",
      study_id: study.id
    }

    %{
      valid_task_params1: valid_task_params1,
      invalid_task_params: invalid_task_params
    }
  end

  describe "create_task/1" do
    test "valid parameters creates task and appends to database", %{
      valid_task_params1: valid_task_params1
    } do
      {:ok, task} = Tasks.create_task(valid_task_params1)
      assert task == Repo.get_by(Task, id: task.id)
    end

    test "invalid parameters does not create task and does not append to database", %{
      invalid_task_params: invalid_task_params
    } do
      {:error, _changeset} = Tasks.create_task(invalid_task_params)
      refute Repo.get_by(Task, content: invalid_task_params[:content])
    end
  end

  describe "change_task/2" do
    test "valid parameters changes a task within the database", %{
      valid_task_params1: valid_task_params1
    } do
      {:ok, task} = Tasks.create_task(valid_task_params1)
      assert {:ok, changed_task} = Tasks.update_task(task, %{content: "Updated Content"})
      assert nil == Tasks.get_task_by(content: valid_task_params1[:content])
      assert changed_task == Tasks.get_task_by(content: "Updated Content")
      assert changed_task.task_number == valid_task_params1[:task_number]
    end

    test "invalid parameters does not change a task within the database", %{
      valid_task_params1: valid_task_params1
    } do
      {:ok, task} = Tasks.create_task(valid_task_params1)
      assert {:error, _changeset} = Tasks.update_task(task, %{content: ""})
      assert nil == Tasks.get_task_by(content: "")

      assert task ==
               Tasks.get_task_by(content: valid_task_params1[:content])
    end
  end

  test "get_task_by/1 returns task with the associated params", %{
    valid_task_params1: valid_task_params1
  } do
    assert nil == Tasks.get_task_by(content: valid_task_params1[:content])

    {:ok, task} = Tasks.create_task(valid_task_params1)

    assert task ==
             Tasks.get_task_by(content: valid_task_params1[:content])

    assert task ==
             Tasks.get_task_by(task_number: valid_task_params1[:task_number])
  end

  test "delete_task/1 deletes a task from the database", %{
    valid_task_params1: valid_task_params1
  } do
    {:ok, task} = Tasks.create_task(valid_task_params1)

    assert task ==
             Tasks.get_task_by(content: valid_task_params1[:content])

    {:ok, _task} = Tasks.delete_task(task)
    refute task == Tasks.get_task_by(content: valid_task_params1[:content])
    refute task == Tasks.get_task_by(task_number: valid_task_params1[:task_number])
  end
end
