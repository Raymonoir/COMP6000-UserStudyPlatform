defmodule Comp6000Web.EndToEnd.StudyTest do
  use Comp6000Web.ConnCase, async: true

  test "When a study is completed, average metrics are calculated from participants", %{
    conn: conn
  } do
    conn =
      post(conn, "/api/users/create", %{
        username: "Ray123",
        email: "Ray123@gmail.com",
        password: "RaysPAssword"
      })

    assert json_response(conn, 200) == %{"created" => "Ray123"}

    conn =
      post(conn, "/api/study/create", %{
        title: "My first study",
        username: "Ray123",
        task_count: 0
      })

    %{"created_study" => _id} = json_response(conn, 200)

    conn = post(conn, "/api/study/get", %{username: "Ray123"})

    %{
      "study" => [
        study
      ]
    } = json_response(conn, 200)

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile_no_err)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile_no_err)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile_no_err)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile_no_err)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile_no_err)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid"}

    conn =
      post(conn, "/api/metrics/current", %{
        participant_uuid: "alonguuid",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{
             "metrics" => %{
               "compile_map" => %{
                 "most_common_error" => ["", 0],
                 "times_compiled" => 5.0
               },
               "replay_map" => %{
                 "idle_time" => 96.105,
                 "insert_character_count" => 492.0,
                 "line_count" => 3.0,
                 "pasted_character_count" => 0.0,
                 "remove_character_count" => 57.0,
                 "total_time" => 88.0,
                 "word_count" => 123.0,
                 "words_per_minute" => 83.86363636363637
               }
             }
           }

    conn =
      post(conn, "/api/study/complete", %{
        study_id: study["id"]
      })

    %{"completed_study" => _id} = json_response(conn, 200)

    conn =
      post(conn, "/api/metrics/study", %{
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{
             "metrics" => %{
               "compile_map" => %{
                 "most_common_error" => ["", 0],
                 "times_compiled" => 5.0
               },
               "replay_map" => %{
                 "idle_time" => 96.105,
                 "insert_character_count" => 492.0,
                 "line_count" => 3.0,
                 "pasted_character_count" => 0.0,
                 "remove_character_count" => 57.0,
                 "total_time" => 88.0,
                 "word_count" => 123.0,
                 "words_per_minute" => 83.86363636363637
               }
             }
           }

    conn =
      post(conn, "/api/metrics/participant", %{
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{
             "metrics" => %{
               "compile" => %{
                 "most_common_error" => ["", 0],
                 "times_compiled" => 5
               },
               "replay" => %{
                 "idle_time" => 96.105,
                 "insert_character_count" => 492,
                 "line_count" => 3,
                 "pasted_character_count" => 0,
                 "remove_character_count" => 57,
                 "total_time" => 88,
                 "word_count" => 123,
                 "words_per_minute" => 83.86363636363637
               }
             }
           }
  end

  test "Check most common error", %{
    conn: conn
  } do
    conn =
      post(conn, "/api/users/create", %{
        username: "Ray123",
        email: "Ray123@gmail.com",
        password: "RaysPAssword"
      })

    assert json_response(conn, 200) == %{"created" => "Ray123"}

    conn =
      post(conn, "/api/study/create", %{
        title: "My first study",
        username: "Ray123",
        task_count: 0
      })

    %{"created_study" => _id} = json_response(conn, 200)

    conn = post(conn, "/api/study/get", %{username: "Ray123"})

    %{
      "study" => [
        study
      ]
    } = json_response(conn, 200)

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile_no_err)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid2"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid2"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile_no_err)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid2"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid2"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid2"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid2"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid2",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid2"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid3"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid3"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid3"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid3"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:compile)),
        data_type: "compile_data",
        study_id: study["id"],
        participant_uuid: "alonguuid3"
      })

    assert json_response(conn, 200) == %{"compile_data_appeneded" => "alonguuid3"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid3",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid3"}

    conn =
      post(conn, "/api/metrics/current", %{
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{
             "metrics" => %{
               "compile_map" => %{
                 "most_common_error" => ["B is not defined", 4],
                 "times_compiled" => 2.0
               },
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

  def testing_data(datatype) do
    case datatype do
      :compile ->
        Jason.decode!(File.read!("test/support/code-examples/loop-arr-error-compile.txt"))

      :compile_no_err ->
        Jason.decode!(File.read!("test/support/code-examples/fib-num-compile.txt"))

      :replay ->
        Jason.decode!(File.read!("test/support/code-examples/for-loop-replay.txt"))
    end
  end
end
