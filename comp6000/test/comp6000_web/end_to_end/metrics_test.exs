defmodule Comp6000Web.EndToEnd.MetricsTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{SurveyQuestions, SurveyAnswers}

  test "sort metrics by option", %{conn: conn} do
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
        participant_uuid: "alonguuid2"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid2"}

    conn =
      post(conn, "/api/data/append", %{
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid2"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid2"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid2",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid2"}

    conn =
      post(conn, "/api/survey/pre/create", %{
        questions: [
          Jason.encode!(%{question: "text question", type: "text"}),
          Jason.encode!(%{
            question: "dropdown question",
            type: "dropdown",
            options: ["option0", "option1", "option2", "option3"]
          }),
          Jason.encode!(%{
            question: "checkbox question",
            type: "checkbox",
            options: ["option1", "option2"]
          })
        ],
        study_id: study["id"]
      })

    assert %{"created_survey_questions" => id} = json_response(conn, 200)

    survey_question = SurveyQuestions.get_survey_question_by(id: id)

    conn =
      post(conn, "/api/survey/pre/submit", %{
        participant_uuid: "alonguuid",
        answers: ["Text answer", "3", "[\"option1\"]"],
        study_id: study["id"]
      })

    assert %{"submitted_survey_answer" => _survey_a_id} = json_response(conn, 200)

    conn =
      post(conn, "/api/survey/pre/submit", %{
        participant_uuid: "alonguuid2",
        answers: ["Text answer", "0", "[\"option1\"]"],
        study_id: study["id"]
      })

    assert %{"submitted_survey_answer" => _survey_a_id} = json_response(conn, 200)

    conn =
      post(conn, "/api/metrics/metrics-for-answers", %{
        "study_id" => study["id"],
        "preposition" => "pre",
        "question_pos" => 1,
        "type" => "avg"
      })

    assert json_response(conn, 200) == %{
             "metrics" => [
               %{
                 "compile_map" => %{"most_common_error" => ["", 0], "times_compiled" => 0.0},
                 "replay_map" => %{
                   "idle_time" => 32.035,
                   "insert_character_count" => 164.0,
                   "line_count" => 1.5,
                   "pasted_character_count" => 0.0,
                   "remove_character_count" => 19.0,
                   "total_time" => 44.0,
                   "word_count" => 41.0,
                   "words_per_minute" => 27.954545454545457
                 }
               },
               %{"compile_map" => %{}, "replay_map" => %{}},
               %{"compile_map" => %{}, "replay_map" => %{}},
               %{
                 "compile_map" => %{"most_common_error" => ["", 0], "times_compiled" => 0.0},
                 "replay_map" => %{
                   "idle_time" => 16.0175,
                   "insert_character_count" => 82.0,
                   "line_count" => 1.5,
                   "pasted_character_count" => 0.0,
                   "remove_character_count" => 9.5,
                   "total_time" => 44.0,
                   "word_count" => 20.5,
                   "words_per_minute" => 13.977272727272728
                 }
               }
             ]
           }

    conn =
      post(conn, "/api/metrics/metrics-for-answers", %{
        "study_id" => study["id"],
        "preposition" => "pre",
        "question_pos" => 1,
        "type" => "full"
      })

    assert %{
             "metrics" => [
               [
                 %{
                   "content" =>
                     "{\"compile\":{\"most_common_error\":[\"\",0],\"times_compiled\":0},\"replay\":{\"idle_time\":64.07,\"insert_character_count\":328,\"line_count\":3,\"pasted_character_count\":0,\"remove_character_count\":38,\"total_time\":88,\"word_count\":82,\"words_per_minute\":55.909090909090914}}",
                   "id" => _id1,
                   "participant_uuid" => "alonguuid2"
                 }
               ],
               [],
               [],
               [
                 %{
                   "content" =>
                     "{\"compile\":{\"most_common_error\":[\"\",0],\"times_compiled\":0},\"replay\":{\"idle_time\":32.035,\"insert_character_count\":164,\"line_count\":3,\"pasted_character_count\":0,\"remove_character_count\":19,\"total_time\":88,\"word_count\":41,\"words_per_minute\":27.954545454545457}}",
                   "id" => _id2,
                   "participant_uuid" => "alonguuid"
                 }
               ]
             ]
           } = json_response(conn, 200)
  end

  test "sort metrics by option 2", %{conn: conn} do
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
        participant_uuid: "alonguuid2"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid2"}

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
        content: Jason.encode!(testing_data(:replay)),
        data_type: "replay_data",
        study_id: study["id"],
        participant_uuid: "alonguuid4"
      })

    assert json_response(conn, 200) == %{"replay_data_appeneded" => "alonguuid4"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid2",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid2"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid3",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid3"}

    conn =
      post(conn, "/api/data/complete", %{
        participant_uuid: "alonguuid4",
        study_id: study["id"]
      })

    assert json_response(conn, 200) == %{"data_completed" => "alonguuid4"}

    conn =
      post(conn, "/api/survey/post/create", %{
        questions: [
          Jason.encode!(%{
            question: "dropdown question",
            type: "dropdown",
            options: ["option0", "option1"]
          })
        ],
        study_id: study["id"]
      })

    assert %{"created_survey_questions" => id} = json_response(conn, 200)

    conn =
      post(conn, "/api/survey/post/submit", %{
        participant_uuid: "alonguuid",
        answers: ["0"],
        study_id: study["id"]
      })

    assert %{"submitted_survey_answer" => _survey_a_id} = json_response(conn, 200)

    conn =
      post(conn, "/api/survey/post/submit", %{
        participant_uuid: "alonguuid2",
        answers: ["1"],
        study_id: study["id"]
      })

    assert %{"submitted_survey_answer" => _survey_a_id} = json_response(conn, 200)

    conn =
      post(conn, "/api/survey/post/submit", %{
        participant_uuid: "alonguuid3",
        answers: ["0"],
        study_id: study["id"]
      })

    assert %{"submitted_survey_answer" => _survey_a_id} = json_response(conn, 200)

    conn =
      post(conn, "/api/survey/post/submit", %{
        participant_uuid: "alonguuid4",
        answers: ["1"],
        study_id: study["id"]
      })

    assert %{"submitted_survey_answer" => _survey_a_id} = json_response(conn, 200)

    conn =
      post(conn, "/api/metrics/metrics-for-answers", %{
        "study_id" => study["id"],
        "preposition" => "post",
        "question_pos" => 0,
        "type" => "full"
      })

    assert %{
             "metrics" => [
               [
                 %{
                   "content" =>
                     "{\"compile\":{\"most_common_error\":[\"\",0],\"times_compiled\":0},\"replay\":{\"idle_time\":32.035,\"insert_character_count\":164,\"line_count\":3,\"pasted_character_count\":0,\"remove_character_count\":19,\"total_time\":88,\"word_count\":41,\"words_per_minute\":27.954545454545457}}",
                   "id" => _9465,
                   "participant_uuid" => "alonguuid3"
                 },
                 %{
                   "content" =>
                     "{\"compile\":{\"most_common_error\":[\"\",0],\"times_compiled\":0},\"replay\":{\"idle_time\":32.035,\"insert_character_count\":164,\"line_count\":3,\"pasted_character_count\":0,\"remove_character_count\":19,\"total_time\":88,\"word_count\":41,\"words_per_minute\":27.954545454545457}}",
                   "id" => _9463,
                   "participant_uuid" => "alonguuid"
                 }
               ],
               [
                 %{
                   "content" =>
                     "{\"compile\":{\"most_common_error\":[\"\",0],\"times_compiled\":0},\"replay\":{\"idle_time\":32.035,\"insert_character_count\":164,\"line_count\":3,\"pasted_character_count\":0,\"remove_character_count\":19,\"total_time\":88,\"word_count\":41,\"words_per_minute\":27.954545454545457}}",
                   "id" => _9466,
                   "participant_uuid" => "alonguuid4"
                 },
                 %{
                   "content" =>
                     "{\"compile\":{\"most_common_error\":[\"\",0],\"times_compiled\":0},\"replay\":{\"idle_time\":32.035,\"insert_character_count\":164,\"line_count\":3,\"pasted_character_count\":0,\"remove_character_count\":19,\"total_time\":88,\"word_count\":41,\"words_per_minute\":27.954545454545457}}",
                   "id" => _9464,
                   "participant_uuid" => "alonguuid2"
                 }
               ]
             ]
           } = json_response(conn, 200)
  end

  def testing_data(datatype) do
    case datatype do
      :compile ->
        Jason.decode!(File.read!("test/support/code-examples/fib-num-compile.txt"))

      :replay ->
        Jason.decode!(File.read!("test/support/code-examples/for-loop-replay.txt"))
    end
  end
end
