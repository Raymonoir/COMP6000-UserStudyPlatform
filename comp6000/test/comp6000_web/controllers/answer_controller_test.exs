defmodule Comp6000Web.AnswerControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks, Answers}

  setup %{conn: conn} do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, task} =
      Tasks.create_task(%{
        task_number: 1,
        content: "What is 2*2?",
        study_id: study.id
      })

    %{conn: conn, study: study, task: task}
  end

  describe "POST /api/answer/create" do
    test "valid parameters creates an answer to a task", %{conn: conn, task: task} do
      answer_data = %{content: "the answer should be 4566"}

      conn = post(conn, "/api/answer/create", Map.put(answer_data, :task_id, task.id))

      result = json_response(conn, 200)

      assert %{"created_answer" => _id} = result
    end

    test "invalid parameters does not create an answer", %{conn: conn, task: task} do
      answer_data = %{not_content: "nope"}

      conn = post(conn, "/api/answer/create", Map.put(answer_data, :task_id, task.id))

      result = json_response(conn, 200)

      assert %{"error" => "content can't be blank"} = result
    end
  end

  describe "POST /api/answer/edit" do
    test "valid parameters edits answer", %{conn: conn, task: task} do
      {:ok, answer} = Answers.create_answer(%{content: "Some content", task_id: task.id})

      conn =
        post(conn, "/api/answer/edit", %{
          answer_id: answer.id,
          content: "different_content"
        })

      result = json_response(conn, 200)
      assert result == %{"updated_answer" => answer.id}
      assert Answers.get_answer_by(id: answer.id).content == "different_content"
    end

    test "invalid parameters does not edit answer", %{conn: conn, task: task} do
      {:ok, answer} = Answers.create_answer(%{content: "Some content", task_id: task.id})

      conn =
        post(conn, "/api/answer/edit", %{
          answer_id: answer.id,
          content: nil
        })

      result = json_response(conn, 200)
      assert result == %{"error" => "content can't be blank"}
      assert Answers.get_answer_by(id: answer.id) == answer
    end
  end

  describe "POST /api/answer/delete" do
    test "valid parameters deletes answer", %{conn: conn, task: task} do
      {:ok, answer} = Answers.create_answer(%{content: "Some content", task_id: task.id})

      conn = post(conn, "/api/answer/delete", %{answer_id: answer.id})

      result = json_response(conn, 200)
      assert result == %{"deleted_answer" => answer.id}
      refute Answers.get_answer_by(id: answer.id)
    end
  end

  describe "POST /api/answer/get" do
    test "valid parameters gets answer", %{conn: conn, task: task} do
      {:ok, answer} = Answers.create_answer(%{content: "Some content", task_id: task.id})

      conn = post(conn, "/api/answer/get", %{answer_id: answer.id})

      %{"answer" => answer_data} = json_response(conn, 200)

      assert answer_data["content"] == answer.content
      assert answer_data["id"] == answer.id
    end
  end
end
