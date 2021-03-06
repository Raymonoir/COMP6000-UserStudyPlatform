defmodule Comp6000Web.StudyControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Studies, Users, Tasks, Metrics, Answers}

  @storage_path Application.get_env(:comp6000, :storage_path)

  setup do
    Users.create_user(%{
      username: "Ray123",
      email: "Ray123@email.com",
      password: "RaysPassword",
      firstname: "Raymond",
      lastname: "Ward"
    })

    :ok
  end

  @valid_study %{
    title: "My Study",
    username: "Ray123",
    participant_code: "123abc"
  }

  @invalid_study %{
    title: "My Study",
    username: "Non-existing Username",
    task_count: 0
  }

  describe "POST /api/study/create" do
    test "valid parameters creates study and directory", %{conn: conn} do
      conn = post(conn, "/api/study/create", @valid_study)

      result = json_response(conn, 200)

      assert %{"created_study" => id} = result

      study = Studies.get_study_by(id: id)

      assert study != nil
      assert study.title == "My Study"

      assert File.exists?("#{@storage_path}/#{id}")
    end

    test "invalid parameters does not creates study or directory", %{conn: conn} do
      conn = post(conn, "/api/study/create", @invalid_study)

      result = json_response(conn, 200)

      assert %{"error" => "user does not exist"} = result
    end
  end

  describe "POST /api/study/edit" do
    test "valid parameters edits study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn =
        post(conn, "/api/study/edit", %{
          study_id: study.id,
          title: "An updated study title"
        })

      json_result = json_response(conn, 200)
      assert %{"updated_study" => _id} = json_result
      assert Studies.get_study_by(id: study.id).title == "An updated study title"
    end

    test "invalid parameters does not edit study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn =
        post(conn, "/api/study/edit", %{
          study_id: study.id,
          title: nil
        })

      json_result = json_response(conn, 200)
      assert %{"error" => "title can't be blank"} == json_result
      assert Studies.get_study_by(id: study.id) == study
    end
  end

  describe "POST /api/study/delete" do
    test "valid parameters edits study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn = post(conn, "/api/study/delete", %{study_id: study.id})

      json_result = json_response(conn, 200)
      assert %{"deleted_study" => _id} = json_result
      refute Studies.get_study_by(id: study.id)
    end
  end

  describe "POST /api/study/get" do
    test "valid participant code returns correct study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn = post(conn, "/api/study/get", %{participant_code: study.participant_code})

      json_result = json_response(conn, 200)

      assert %{
               "study" => %{
                 "task_count" => 0,
                 "tasks" => [],
                 "title" => "My Study",
                 "username" => "Ray123"
               }
             } = json_result
    end

    test "invalid participant code returns no study", %{conn: conn} do
      {:ok, _study} = Studies.create_study(@valid_study)

      conn = post(conn, "/api/study/get", %{participant_code: "jibjabjob"})

      json_result = json_response(conn, 200)

      assert %{"study" => nil} = json_result
    end

    test "valid id returns all information for a study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      {:ok, task1} = Tasks.create_task(%{study_id: study.id, content: "What is life?"})

      {:ok, task2} =
        Tasks.create_task(%{
          study_id: study.id,
          content: "How are you?",
          optional_info: "background"
        })

      {:ok, answer} =
        Answers.create_answer(%{
          content: "How are you?",
          task_id: task1.id
        })

      {:ok, _result} =
        Metrics.create_metrics(%{
          study_id: study.id,
          participant_uuid: "7876rer"
        })

      conn = post(conn, "/api/study/get", %{study_id: study.id})

      %{
        "study" => %{
          "id" => study_id,
          "participant_code" => _code,
          "participant_count" => 1,
          "participant_max" => nil,
          "participant_list" => ["7876rer"],
          "task_count" => task_count,
          "tasks" => [
            %{
              "answer" => %{"content" => "How are you?", "id" => answer_id},
              "content" => "What is life?",
              "id" => task1_id,
              "optional_info" => nil,
              "task_number" => task1_number
            },
            %{
              "content" => "How are you?",
              "id" => task2_id,
              "optional_info" => "background",
              "task_number" => task2_number
            }
          ],
          "title" => "My Study",
          "username" => "Ray123"
        }
      } = json_response(conn, 200)

      study = Studies.get_study_by(id: study.id)
      assert study_id == study.id
      assert task_count == study.task_count
      assert task1_id == task1.id
      assert task1_number == task1.task_number

      assert task2_id == task2.id
      assert task2_number == task2.task_number

      assert answer_id == answer.id
    end

    test "invalid id returns no study", %{conn: conn} do
      {:ok, _study} = Studies.create_study(@valid_study)

      conn = post(conn, "/api/study/get", %{study_id: "7dg"})

      json_result = json_response(conn, 200)

      assert %{"study" => nil} = json_result
    end
  end

  describe "POST /api/study/complete" do
    test "completes study by removing participant code", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      post(conn, "/api/study/complete", %{
        study_id: study.id
      })

      study = Studies.get_study_by(id: study.id)

      assert study.participant_code == nil
    end
  end
end
