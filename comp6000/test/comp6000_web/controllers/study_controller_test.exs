defmodule Comp6000Web.Study.StudyControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Studies, Users, Tasks, Results, Answers}

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
    username: "Ray123"
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

  describe "GET /api/study/get-by/participant_code/:participant_code" do
    test "valid participant code returns correct study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn = get(conn, "/api/study/get-by/participant-code/#{study.participant_code}")

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

      conn = get(conn, "/api/study/get-by/participant-code/jibber-jabber")

      json_result = json_response(conn, 200)

      assert %{"study" => nil} = json_result
    end
  end

  describe "GET /api/study/get-by/id/:id" do
    test "valid id returns correct study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn = get(conn, "/api/study/get-by/id/#{study.id}")

      json_result = json_response(conn, 200)

      id = study.id

      assert %{
               "study" => %{
                 "task_count" => 0,
                 "tasks" => [],
                 "title" => "My Study",
                 "username" => "Ray123",
                 "id" => ^id
               }
             } = json_result
    end

    test "invalid id returns no study", %{conn: conn} do
      {:ok, _study} = Studies.create_study(@valid_study)

      conn = get(conn, "/api/study/get-by/id/5678905678")

      json_result = json_response(conn, 200)

      assert %{"study" => nil} = json_result
    end
  end

  describe "POST /api/study/:study_id/edit" do
    test "valid parameters edits study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn =
        post(conn, "/api/study/#{study.id}/edit", %{
          title: "An updated study title"
        })

      json_result = json_response(conn, 200)
      assert %{"updated_study" => _id} = json_result
      assert Studies.get_study_by(id: study.id).title == "An updated study title"
    end

    test "invalid parameters does not edit study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn =
        post(conn, "/api/study/#{study.id}/edit", %{
          title: nil
        })

      json_result = json_response(conn, 200)
      assert %{"error" => "title can't be blank"} == json_result
      assert Studies.get_study_by(id: study.id) == study
    end
  end

  describe "GET /api/study/:study_id/delete" do
    test "valid parameters edits study", %{conn: conn} do
      {:ok, study} = Studies.create_study(@valid_study)

      conn = get(conn, "/api/study/#{study.id}/delete")

      json_result = json_response(conn, 200)
      assert %{"deleted_study" => _id} = json_result
      refute Studies.get_study_by(id: study.id)
    end
  end

  describe "GET /api/study/:study_id/get-all" do
    test "valid parameters returns all information for a study", %{conn: conn} do
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
        Results.create_result(%{
          task_id: task1.id,
          content: "Life is life",
          unique_participant_id: "7876rer"
        })

      conn = get(conn, "/api/study/#{study.id}/get-all")

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
  end
end
