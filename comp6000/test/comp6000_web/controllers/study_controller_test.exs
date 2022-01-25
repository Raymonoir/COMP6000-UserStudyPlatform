defmodule Comp6000Web.Study.StudyControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Studies, Users}

  @storage_path Application.get_env(:comp6000, :storage_directory_path)

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
    task_count: 0
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
      {:ok, study} = Studies.create_study(@valid_study)

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
      {:ok, study} = Studies.create_study(@valid_study)

      conn = get(conn, "/api/study/get-by/id/5678905678")

      json_result = json_response(conn, 200)

      assert %{"study" => nil} = json_result
    end
  end
end
