defmodule Comp6000Web.Study.ResultControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks, Results}

  @storage_path Application.get_env(:comp6000, :storage_directory_path)
  @storage_file_extension Application.get_env(:comp6000, :storage_file_extension)
  @completed_file_extension Application.get_env(:comp6000, :completed_file_extension)

  setup %{conn: conn} do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, bg_task} =
      Tasks.create_task(%{
        task_number: 1,
        content: "Where you from?",
        study_id: study.id,
        optional_info: "background"
      })

    {:ok, task} =
      Tasks.create_task(%{
        task_number: 1,
        content: "What is 2*2?",
        study_id: study.id
      })

    %{conn: conn, study: study, bg_task: bg_task, task: task}
  end

  @result_json %{content: "content"}
  @invalid_result_json %{
    data: "invalid"
  }

  describe "POST /api/study/:study_id/background/:uuid/submit" do
    test "valid parameters submits background result", %{
      conn: conn,
      study: study,
      bg_task: bg_task
    } do
      # This would normally be taken from the session
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/study/#{study.id}/background/#{uuid}/submit",
          @result_json
        )

      result = Results.get_result_by(task_id: bg_task.id)
      assert result
      assert result.content == "content"
      assert result.unique_participant_id == uuid

      result = json_response(conn, 200)

      assert %{
               "background_result_created" => %{
                 "content" => "content",
                 "id" => _id,
                 "unique_participant_id" => _uuid
               }
             } = result
    end

    test "invalid parameters does not submit background result", %{
      conn: conn,
      study: study,
      bg_task: bg_task
    } do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/study/#{study.id}/background/#{uuid}/submit",
          @invalid_result_json
        )

      result = Results.get_result_by(task_id: bg_task.id)
      refute result

      result = json_response(conn, 200)

      assert %{
        "invalid_background_parameters" =>
          %{
            "data" => "invalid",
            "study_id" => study.id,
            "uuid" => uuid
          } == result
      }
    end
  end

  describe "POST /study/api/:study_id/task/:task_id/:uuid/result/submit" do
    test "valid parameters submit result", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/result/submit",
          @result_json
        )

      result = Results.get_result_by(task_id: task.id)
      assert result
      assert result.content == "content"
      assert result.unique_participant_id == uuid

      json_result = json_response(conn, 200)

      assert %{
        "result_created" =>
          %{
            "content" => "content",
            "id" => result.id,
            "unique_participant_id" => uuid
          } == json_result
      }
    end

    test "invalid parameters does not submit result", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/result/submit",
          @invalid_result_json
        )

      result = json_response(conn, 200)

      assert %{
        "invalid_result_parameters" =>
          %{
            "data" => "invalid",
            "study_id" => study.id,
            "task_id" => task.id,
            "uuid" => uuid
          } == result
      }

      result = Results.get_result_by(task_id: task.id)
      refute result
    end
  end

  # post(
  #   "/:study_id/task/:task_id/:uuid/replay_data/append",
  #   ResultController,
  #   :append_replay_data
  # )
  describe "POST /api/study/:study_id/task/:task_id/:uuid/replay_data/append" do
    test "valid parameters appends replay data", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/replay_data/append",
          @result_json
        )

      path = "#{@storage_path}/#{study.id}/#{task.id}/#{uuid}.#{@storage_file_extension}"

      assert File.exists?(path)

      assert json_response(conn, 200) == %{"result_appeneded" => "ok"}

      assert "[content" == File.read!(path)
    end
  end

  # get(
  #   "/:study_id/task/:task_id/:uuid/code/complete",
  #   ResultController,
  #   :complete_replay_data
  # )

  describe "GET /api/study/:study_id/task/:task_id/:uuid/replay_data/complete" do
    test "valid parameters completes replay_data", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()
      content = "Some Content!"

      Results.create_result(%{
        task_id: task.id,
        content: "placeholder",
        unique_participant_id: uuid
      })

      path = "#{@storage_path}/#{study.id}/#{task.id}/#{uuid}"

      File.write(
        "#{path}.#{@storage_file_extension}",
        content
      )

      conn =
        get(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/replay_data/complete"
        )

      assert json_response(conn, 200) == %{"result_completed" => "ok"}

      assert File.exists?("#{path}.#{@completed_file_extension}")
      refute File.exists?("#{path}.#{@storage_file_extension}")

      assert File.read!("#{path}.#{@completed_file_extension}") == :zlib.gzip(content)
    end
  end
end
