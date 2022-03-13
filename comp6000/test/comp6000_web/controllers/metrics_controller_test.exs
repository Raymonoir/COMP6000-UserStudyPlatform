defmodule Comp6000Web.MetricsControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks, Metrics}

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

  describe "POST /api/data/append" do
    test "valid parameters appends replay data", %{conn: conn, study: study} do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/data/append",
          %{
            content: "content",
            data_type: "replay_data",
            study_id: study.id,
            participant_uuid: uuid
          }
        )

      path = "#{@storage_path}/#{study.id}/#{uuid}/#{@replay_filename}.#{@extension}"

      assert File.exists?(path)

      assert json_response(conn, 200) == %{"replay_data_appeneded" => "ok"}

      assert "#{@file_start}content" == File.read!(path)

      post(
        conn,
        "/api/data/append",
        %{
          content: "content",
          data_type: "replay_data",
          study_id: study.id,
          participant_uuid: uuid
        }
      )

      assert "#{@file_start}content#{@chunk_delimiter}content" == File.read!(path)
    end

    test "valid parameters appends compile data", %{conn: conn, study: study} do
      uuid = UUID.uuid4()

      conn =
        post(
          conn,
          "/api/data/append",
          %{
            content: "content",
            data_type: "compile_data",
            study_id: study.id,
            participant_uuid: uuid
          }
        )

      path = "#{@storage_path}/#{study.id}/#{uuid}/#{@compile_filename}.#{@extension}"

      assert File.exists?(path)

      assert json_response(conn, 200) == %{"compile_data_appeneded" => "ok"}

      assert "#{@file_start}content" == File.read!(path)

      post(
        conn,
        "/api/data/append",
        %{
          content: "content",
          data_type: "compile_data",
          study_id: study.id,
          participant_uuid: uuid
        }
      )

      assert "#{@file_start}content#{@chunk_delimiter}content" == File.read!(path)
    end
  end

  describe "POST /api/data/complete" do
    test "valid parameters completes replay_data", %{conn: conn, study: study} do
      uuid = UUID.uuid4()
      content = "Some Content!"

      Metrics.create_metrics(%{
        study_id: study.id,
        participant_uuid: uuid
      })

      path = "#{@storage_path}/#{study.id}/#{uuid}/#{@replay_filename}"

      File.write(
        "#{path}.#{@extension}",
        "#{@file_start}#{content}"
      )

      conn =
        post(
          conn,
          "/api/data/complete",
          %{
            participant_uuid: uuid,
            study_id: study.id,
            data_type: "replay_data",
            content: "content"
          }
        )

      assert json_response(conn, 200) == %{"replay_data_completed" => "ok"}

      assert File.exists?("#{path}.#{@completed_extension}")
      refute File.exists?("#{path}.#{@extension}")

      assert File.read!("#{path}.#{@completed_extension}") ==
               :zlib.gzip("#{@file_start}#{content}#{@file_end}")
    end

    test "valid parameters completes compile_data", %{conn: conn, study: study} do
      uuid = UUID.uuid4()
      content = "Some Content!"

      Metrics.create_metrics(%{
        study_id: study.id,
        participant_uuid: uuid
      })

      path = "#{@storage_path}/#{study.id}/#{uuid}/#{@compile_filename}"

      File.write(
        "#{path}.#{@extension}",
        "#{@file_start}#{content}"
      )

      conn =
        post(
          conn,
          "/api/data/complete",
          %{
            participant_uuid: uuid,
            study_id: study.id,
            data_type: "compile_data",
            content: "content"
          }
        )

      assert json_response(conn, 200) == %{"compile_data_completed" => "ok"}

      assert File.exists?("#{path}.#{@completed_extension}")
      refute File.exists?("#{path}.#{@extension}")

      assert File.read!("#{path}.#{@completed_extension}") ==
               :zlib.gzip("#{@file_start}#{content}#{@file_end}")
    end
  end
end
