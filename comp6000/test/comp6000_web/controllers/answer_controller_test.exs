defmodule Comp6000Web.Study.AnswerControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks}

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

  describe "POST /api/study/:study_id/task/:id/answer/create" do
    test "valid parameters creates an answer to a task", %{conn: conn, task: task, study: study} do
      answer_data = %{content: "the answer should be 4566"}

      conn = post(conn, "/api/study/#{study.id}/task/#{task.id}/answer/create", answer_data)

      result = json_response(conn, 200)

      assert %{"created_answer" => _id} = result
    end

    test "invalid parameters does not create an answer", %{conn: conn, task: task, study: study} do
      answer_data = %{not_content: "nope"}

      conn = post(conn, "/api/study/#{study.id}/task/#{task.id}/answer/create", answer_data)

      result = json_response(conn, 200)

      assert %{"error" => "content can't be blank"} = result
    end
  end
end
