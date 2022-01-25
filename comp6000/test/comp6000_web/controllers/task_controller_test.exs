defmodule Comp6000Web.Study.TaskControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks}

  @storage_path Application.get_env(:comp6000, :storage_directory_path)

  setup %{conn: conn} do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    task1 = %{
      task_number: 1,
      content: "What is 2*2?",
      study_id: study.id
    }

    task2 = %{
      task_number: 2,
      content: "What is 2*3?",
      study_id: study.id
    }

    task3 = %{
      task_number: 3,
      content: "What is 2*4?",
      study_id: study.id
    }

    %{conn: conn, task1: task1, task2: task2, task3: task3}
  end

  @invalid_task %{
    task_number: 10
  }

  describe "POST /api/study/:study_id/task/create" do
    test "valid parameters creates task and directory", %{conn: conn, task1: task1} do
      conn = post(conn, "/api/study/#{task1.study_id}/task/create", task1)

      result = json_response(conn, 200)

      assert %{"created_task" => id} = result

      stored_task = Tasks.get_task_by(id: id)

      assert stored_task

      assert stored_task.content == task1.content

      assert File.exists?("#{@storage_path}/#{task1.study_id}/#{stored_task.id}")
    end

    test "invalid parameters does not create task or directory", %{conn: conn, task1: task1} do
      conn = post(conn, "/api/study/#{task1.study_id}/task/create", @invalid_task)

      result = json_response(conn, 200)

      assert %{"error" => "content can't be blank"} = result
    end
  end

  describe "GET /api/study/:study_id/get-tasks" do
    test "valid study_id returns all created tasks", %{
      conn: conn,
      task1: task1,
      task2: task2,
      task3: task3
    } do
      {:ok, task1} = Tasks.create_task(task1)
      {:ok, task2} = Tasks.create_task(task2)
      {:ok, task3} = Tasks.create_task(task3)

      conn = get(conn, "/api/study/#{task1.study_id}/get-tasks")

      result = json_response(conn, 200)

      assert %{"tasks_for_study" => list} = result

      assert length(list) == 3

      assert Enum.at(list, 0)["id"] == task1.id
      assert Enum.at(list, 1)["id"] == task2.id
      assert Enum.at(list, 2)["id"] == task3.id
    end

    test "invalid study_id returns empty list", %{
      conn: conn,
      task1: task1,
      task2: task2,
      task3: task3
    } do
      {:ok, task1} = Tasks.create_task(task1)
      {:ok, task2} = Tasks.create_task(task2)
      {:ok, task3} = Tasks.create_task(task3)

      conn = get(conn, "/api/study/0/get-tasks")

      result = json_response(conn, 200)

      assert %{"invalid_study" => []} = result
    end
  end
end
