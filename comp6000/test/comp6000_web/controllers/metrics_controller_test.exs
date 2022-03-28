defmodule Comp6000Web.MetricsControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks, Metrics, Storage}
  alias Comp6000.ReplayMetrics.Calculations

  @storage_path Application.get_env(:comp6000, :storage_path)
  @extension Application.get_env(:comp6000, :extension)
  @completed_extension Application.get_env(:comp6000, :completed_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)
  @file_start Application.get_env(:comp6000, :file_start)
  @file_end Application.get_env(:comp6000, :file_end)
  @compile_filename Application.get_env(:comp6000, :compile_filename)
  @replay_filename Application.get_env(:comp6000, :replay_filename)

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

      assert json_response(conn, 200) == %{"replay_data_appeneded" => uuid}

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

      assert json_response(conn, 200) == %{"compile_data_appeneded" => uuid}

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
      content = Jason.encode!(%{start: 1_645_537_625_744, end: 1_645_589_625_780, events: []})

      Metrics.create_metrics(%{
        content: Jason.encode!(%{}),
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
            data_type: "replay_data"
          }
        )

      assert json_response(conn, 200) == %{"data_completed" => uuid}

      assert File.exists?("#{path}.#{@completed_extension}")
      refute File.exists?("#{path}.#{@extension}")

      assert File.read!("#{path}.#{@completed_extension}") ==
               :zlib.gzip("#{@file_start}#{content}#{@file_end}")
    end

    test "valid parameters completes compile_data", %{conn: conn, study: study} do
      uuid = UUID.uuid4()

      content =
        Jason.encode!(%{"start" => 1_645_537_625_744, "end" => 1_645_589_625_780, events: []})

      Metrics.create_metrics(%{
        study_id: study.id,
        participant_uuid: uuid,
        content: Jason.encode!(%{})
      })

      path = "#{@storage_path}/#{study.id}/#{uuid}/#{@compile_filename}"

      File.write(
        "#{path}.#{@extension}",
        "#{@file_start}#{content}"
      )

      conn =
        post(
          conn,
          "/api/data/append",
          %{
            participant_uuid: uuid,
            study_id: study.id,
            data_type: "replay_data",
            content: content
          }
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

      assert json_response(conn, 200) == %{"data_completed" => uuid}

      assert File.exists?("#{path}.#{@completed_extension}")
      refute File.exists?("#{path}.#{@extension}")

      assert File.read!("#{path}.#{@completed_extension}") ==
               :zlib.gzip("#{@file_start}#{content}#{@file_end}")
    end
  end

  describe "POST /api/metrics/participant" do
    test "valid parameters returns metrics for a participant", %{conn: conn, study: study} do
      uuid = UUID.uuid4()
      content = Jason.encode!(testing_data(:replay))

      complete_replay_data(uuid, study.id, content)

      conn =
        post(conn, "/api/metrics/participant", %{
          participant_uuid: uuid
        })

      assert json_response(conn, 200) == %{
               "metrics_for_participant" => %{
                 "compile" => %{},
                 "replay" => %{
                   "idle_time" => 32.035,
                   "insert_character_count" => 164,
                   "line_count" => 3,
                   "pasted_character_count" => 0,
                   "remove_character_count" => 19,
                   "total_time" => 88,
                   "word_count" => 41,
                   "words_per_minute" => 27.954545454545457
                 }
               }
             }
    end
  end

  describe "POST /api/metrics/current" do
    test "returns average metrics whilst study is still open", %{conn: conn, study: study} do
      replay_content = Jason.encode!(testing_data(:replay))

      uuid1 = UUID.uuid4()
      complete_replay_data(uuid1, study.id, replay_content)

      conn = post(conn, "/api/metrics/current", %{study_id: study.id})

      assert json_response(conn, 200) == %{
               "metrics_for_participant" => %{
                 "compile_map" => %{},
                 "replay_map" => %{
                   "idle_time" => 32.035,
                   "insert_character_count" => 164.0,
                   "line_count" => 3.0,
                   "pasted_character_count" => 0.0,
                   "remove_character_count" => 19.0,
                   "total_time" => 88.0,
                   "word_count" => 41.0,
                   "words_per_minute" => 27.954545454545457
                 }
               }
             }

      uuid2 = UUID.uuid4()
      complete_replay_data(uuid2, study.id, replay_content)

      conn = post(conn, "/api/metrics/current", %{study_id: study.id})

      assert json_response(conn, 200) == %{
               "metrics_for_participant" => %{
                 "compile_map" => %{},
                 "replay_map" => %{
                   "idle_time" => 32.035,
                   "insert_character_count" => 164.0,
                   "line_count" => 3.0,
                   "pasted_character_count" => 0.0,
                   "remove_character_count" => 19.0,
                   "total_time" => 88.0,
                   "word_count" => 41.0,
                   "words_per_minute" => 27.954545454545457
                 }
               }
             }

      uuid3 = UUID.uuid4()
      complete_compile_data(uuid3, study.id, replay_content)

      conn = post(conn, "/api/metrics/current", %{study_id: study.id})

      assert json_response(conn, 200) == %{
               "metrics_for_participant" => %{
                 "compile_map" => %{
                   "most_common_error" => [],
                   "times_compiled" => 0.3333333333333333
                 },
                 "replay_map" => %{
                   "idle_time" => 21.356666666666666,
                   "insert_character_count" => 109.33333333333333,
                   "line_count" => 2.0,
                   "pasted_character_count" => 0.0,
                   "remove_character_count" => 12.666666666666666,
                   "total_time" => 58.666666666666664,
                   "word_count" => 27.333333333333332,
                   "words_per_minute" => 18.636363636363637
                 }
               }
             }
    end
  end

  describe "POST /api/metrics/study" do
    test "valid parameters returns average metrics for study", %{conn: conn, study: study} do
      replay_content = Jason.encode!(testing_data(:replay))

      uuid1 = UUID.uuid4()
      complete_replay_data(uuid1, study.id, replay_content)

      uuid2 = UUID.uuid4()
      complete_replay_data(uuid2, study.id, replay_content)

      uuid3 = UUID.uuid4()
      complete_replay_data(uuid3, study.id, replay_content)

      {:ok, study} = Studies.update_study(study, %{participant_list: [uuid1, uuid2, uuid3]})

      metrics_map = Calculations.get_average_study_metrics(study)

      Metrics.create_metrics(%{
        content: Jason.encode!(metrics_map),
        participant_uuid: Integer.to_string(study.id),
        study_id: study.id
      })

      conn = post(conn, "/api/metrics/study", %{study_id: study.id})

      assert json_response(conn, 200) == %{
               "metrics_for_study" => %{
                 "compile_map" => %{},
                 "replay_map" => %{
                   "idle_time" => 32.035,
                   "insert_character_count" => 164.0,
                   "line_count" => 3.0,
                   "pasted_character_count" => 0.0,
                   "remove_character_count" => 19.0,
                   "total_time" => 88.0,
                   "word_count" => 41.0,
                   "words_per_minute" => 27.954545454545457
                 }
               }
             }
    end
  end

  def complete_replay_data(uuid, study_id, content) do
    {:ok, metrics} =
      Metrics.create_metrics(%{
        study_id: study_id,
        participant_uuid: uuid,
        content: Jason.encode!(%{})
      })

    path = "#{@storage_path}/#{study_id}/#{uuid}/#{@replay_filename}"

    File.write(
      "#{path}.#{@extension}",
      "#{@file_start}#{content}"
    )

    Storage.complete_data(metrics, :replay)
    replay_map = Calculations.calculate_metrics(metrics, :replay)

    Metrics.update_metrics(metrics, %{
      content: Jason.encode!(%{replay: replay_map, compile: %{}})
    })
  end

  def complete_compile_data(uuid, study_id, content) do
    {:ok, metrics} =
      Metrics.create_metrics(%{
        study_id: study_id,
        participant_uuid: uuid,
        content: Jason.encode!(%{})
      })

    path = "#{@storage_path}/#{study_id}/#{uuid}/#{@compile_filename}"

    File.write(
      "#{path}.#{@extension}",
      "#{@file_start}#{content}"
    )

    Storage.complete_data(metrics, :compile)
    compile_map = Calculations.calculate_metrics(metrics, :compile)

    Metrics.update_metrics(metrics, %{
      content: Jason.encode!(%{replay: %{}, compile: compile_map})
    })
  end

  def testing_data(datatype) do
    case datatype do
      :compile ->
        Jason.decode!(File.read!("test/support/code-examples/for-loop-compile.txt"))

      :replay ->
        Jason.decode!(File.read!("test/support/code-examples/for-loop-replay.txt"))
    end
  end
end
