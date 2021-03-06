defmodule Comp6000Web.TaskControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks}

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

  describe "POST /api/task/create" do
    test "valid parameters creates single task and directory", %{conn: conn, task1: task1} do
      conn = post(conn, "/api/task/create", %{tasks: [task1]})

      result = json_response(conn, 200)

      %{"created_tasks" => [id]} = result

      stored_task = Tasks.get_task_by(id: id)

      assert stored_task

      assert stored_task.content == task1.content
    end

    test "valid parameters creates multiple tasks", %{
      conn: conn,
      task2: task2,
      task3: task3
    } do
      conn = post(conn, "/api/task/create", %{tasks: [task2, task3]})

      result = json_response(conn, 200)

      %{"created_tasks" => [id2, id3]} = result

      stored_task2 = Tasks.get_task_by(id: id2)
      stored_task3 = Tasks.get_task_by(id: id3)

      assert stored_task2
      assert stored_task3

      assert stored_task2.content == task2.content
      assert stored_task3.content == task3.content

      # assert File.exists?("#{@storage_path}/#{task1.study_id}/#{stored_task.id}")
    end

    test "both valid and invalid parameters creates tasks where possible", %{
      conn: conn,
      task1: task1
    } do
      conn = post(conn, "/api/task/create", %{tasks: [task1, @invalid_task]})

      result = json_response(conn, 200)

      %{"created_tasks" => [id, "content can't be blank,study_id can't be blank"]} = result

      stored_task = Tasks.get_task_by(id: id)

      assert stored_task

      assert stored_task.content == task1.content

      # assert File.exists?("#{@storage_path}/#{task1.study_id}/#{stored_task.id}")
    end

    test "invalid parameters does not create task or directory", %{conn: conn} do
      conn = post(conn, "/api/task/create", %{tasks: [@invalid_task]})

      result = json_response(conn, 200)

      assert %{"created_tasks" => ["content can't be blank,study_id can't be blank"]} == result
    end
  end

  describe "POST /api/task/get" do
    test "valid study_id returns all created tasks", %{
      conn: conn,
      task1: task1,
      task2: task2,
      task3: task3
    } do
      {:ok, task1} = Tasks.create_task(task1)
      {:ok, task2} = Tasks.create_task(task2)
      {:ok, task3} = Tasks.create_task(task3)

      conn = post(conn, "/api/task/get", %{study_id: task1.study_id})

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
      {:ok, _task1} = Tasks.create_task(task1)
      {:ok, _task2} = Tasks.create_task(task2)
      {:ok, _task3} = Tasks.create_task(task3)

      conn = post(conn, "/api/task/get", %{study_id: "123456789"})

      result = json_response(conn, 200)

      assert %{"tasks_for_study" => nil} = result
    end
  end
end
