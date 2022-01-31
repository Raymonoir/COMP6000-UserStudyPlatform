defmodule Comp6000Web.Study.ResultControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks, Results}

  @storage_path Application.get_env(:comp6000, :storage_path)
  @extension Application.get_env(:comp6000, :extension)
  @completed_extension Application.get_env(:comp6000, :completed_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)
  @file_start Application.get_env(:comp6000, :file_start)
  @file_end Application.get_env(:comp6000, :file_end)
  @compile_filename Application.get_env(:comp6000, :compile_filename)
  @replay_filename Application.get_env(:comp6000, :compile_filename)

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

  describe "POST /api/study/:study_id/task/:task_id/:uuid/replay-data/append" do
    test "valid parameters appends replay data", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/replay-data/append",
          @result_json
        )

      path = "#{@storage_path}/#{study.id}/#{task.id}/#{uuid}/#{@replay_filename}.#{@extension}"

      assert File.exists?(path)

      assert json_response(conn, 200) == %{"replay-data_appeneded" => "ok"}

      assert "#{@file_start}content" == File.read!(path)

      post(
        conn,
        "/api/study/#{study.id}/task/#{task.id}/#{uuid}/replay-data/append",
        @result_json
      )

      assert "#{@file_start}content#{@chunk_delimiter}content" == File.read!(path)
    end

    test "valid parameters appends compile data", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/compile-data/append",
          @result_json
        )

      path = "#{@storage_path}/#{study.id}/#{task.id}/#{uuid}/#{@compile_filename}.#{@extension}"

      assert File.exists?(path)

      assert json_response(conn, 200) == %{"compile-data_appeneded" => "ok"}

      assert "#{@file_start}content" == File.read!(path)

      post(
        conn,
        "/api/study/#{study.id}/task/#{task.id}/#{uuid}/compile-data/append",
        @result_json
      )

      assert "#{@file_start}content#{@chunk_delimiter}content" == File.read!(path)
    end
  end

  describe "GET /api/study/:study_id/task/:task_id/:uuid/replay-data/complete" do
    test "valid parameters completes replay_data", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()
      content = "Some Content!"

      Results.create_result(%{
        task_id: task.id,
        content: "placeholder",
        unique_participant_id: uuid
      })

      path = "#{@storage_path}/#{study.id}/#{task.id}/#{uuid}/#{@replay_filename}"

      File.write(
        "#{path}.#{@extension}",
        "#{@file_start}#{content}"
      )

      conn =
        get(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/replay-data/complete"
        )

      assert json_response(conn, 200) == %{"replay-data_completed" => "ok"}

      assert File.exists?("#{path}.#{@completed_extension}")
      refute File.exists?("#{path}.#{@extension}")

      assert File.read!("#{path}.#{@completed_extension}") ==
               :zlib.gzip("#{@file_start}#{content}#{@file_end}")
    end

    test "valid parameters completes compile_data", %{conn: conn, study: study, task: task} do
      uuid = UUID.uuid4()
      content = "Some Content!"

      Results.create_result(%{
        task_id: task.id,
        content: "placeholder",
        unique_participant_id: uuid
      })

      path = "#{@storage_path}/#{study.id}/#{task.id}/#{uuid}/#{@compile_filename}"

      File.write(
        "#{path}.#{@extension}",
        "#{@file_start}#{content}"
      )

      conn =
        get(
          conn,
          "/api/study/#{study.id}/task/#{task.id}/#{uuid}/compile-data/complete"
        )

      assert json_response(conn, 200) == %{"compile-data_completed" => "ok"}

      assert File.exists?("#{path}.#{@completed_extension}")
      refute File.exists?("#{path}.#{@extension}")

      assert File.read!("#{path}.#{@completed_extension}") ==
               :zlib.gzip("#{@file_start}#{content}#{@file_end}")
    end
  end

  describe "GET /api/study/:study_id/task/:task_id/get-results" do
    test "valid parameters returns results", %{conn: conn, study: study, task: task} do
      conn = get(conn, "/api/study/#{study.id}/task/#{task.id}/get-results")

      assert json_response(conn, 200) == %{"results" => []}

      {:ok, result1} =
        Results.create_result(%{
          unique_participant_id: "sudbsdbjh",
          content: "Content!",
          task_id: task.id
        })

      {:ok, result2} =
        Results.create_result(%{
          unique_participant_id: "45678iuhgf",
          content: "Content2!",
          task_id: task.id
        })

      conn = get(conn, "/api/study/#{study.id}/task/#{task.id}/get-results")

      %{"results" => [returned_result1, returned_result2]} = json_response(conn, 200)

      assert returned_result1["id"] == result1.id
      assert returned_result2["id"] == result2.id
    end
  end
end
