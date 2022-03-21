defmodule Comp6000Web.SurveyControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Studies, Users, SurveyQuestions, SurveyAnswers}

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    valid_q_params = %{study_id: study.id, questions: ["q1", "q2", "q3"]}

    invalid_q_params = %{study_id: study.id}

    valid_a_params = %{
      study_id: study.id,
      participant_uuid: "uuidv4",
      answers: ["a1", "a2", "a3"]
    }

    invalid_a_params = %{answers: ["a1", "a2", "a3"]}

    %{
      user: user,
      study: study,
      valid_q_params: valid_q_params,
      invalid_q_params: invalid_q_params,
      valid_a_params: valid_a_params,
      invalid_a_params: invalid_a_params
    }
  end

  describe "POST /api/survey/pre/create" do
    test "valid parameters creates a pre study survey", context do
      post(context[:conn], "/api/survey/pre/create", context[:valid_q_params])

      question =
        SurveyQuestions.get_survey_question_by(study_id: context[:valid_q_params].study_id)

      assert question
      assert question.study_id == context[:valid_q_params].study_id
      assert question.questions == context[:valid_q_params].questions
      assert question.preposition == "pre"
    end

    test "invalid parameters does not create a pre study survey", context do
      post(context[:conn], "/api/survey/pre/create", context[:invalid_q_params])

      question =
        SurveyQuestions.get_survey_question_by(study_id: context[:invalid_q_params].study_id)

      refute question
    end
  end

  describe "POST /api/survey/pre/get" do
    test "valid parameters gets a pre study survey", context do
      {:ok, question} =
        SurveyQuestions.create_survey_question(
          Map.put(context[:valid_q_params], :preposition, "pre")
        )

      conn = post(context[:conn], "/api/survey/pre/get", %{study_id: question.study_id})

      assert json_response(conn, 200) == %{
               "survey_question" => %{
                 "id" => question.id,
                 "preposition" => "pre",
                 "questions" => ["q1", "q2", "q3"]
               }
             }
    end

    test "invalid parameters does not get a pre study survey", context do
      conn = post(context[:conn], "/api/survey/pre/get", %{study_id: 98_765_456_789})

      json_result = json_response(conn, 200)

      assert json_result == %{"survey_question" => nil}

      refute SurveyQuestions.get_survey_question_by(study_id: context[:invalid_q_params].study_id)
    end
  end

  describe "POST /api/survey/pre/submit" do
    test "valid parameters submits an answer to pre study survey", context do
      {:ok, question} =
        SurveyQuestions.create_survey_question(
          Map.put(context[:valid_q_params], :preposition, "pre")
        )

      post(context[:conn], "/api/survey/pre/submit", context[:valid_a_params])

      answer = SurveyAnswers.get_survey_answer_by(survey_question_id: question.id)

      assert answer
    end

    test "invalid parameters does not submit an answer to pre study survey", context do
      {:ok, _question} =
        SurveyQuestions.create_survey_question(
          Map.put(context[:valid_q_params], :preposition, "pre")
        )

      post(context[:conn], "/api/survey/pre/submit", context[:invalid_a_params])

      answer = SurveyAnswers.get_survey_answer_by(answers: context[:invalid_a_params].answers)

      refute answer
    end
  end

  describe "POST /api/survey/post/create" do
    test "valid parameters creates a post study survey", context do
      post(context[:conn], "/api/survey/post/create", context[:valid_q_params])

      question =
        SurveyQuestions.get_survey_question_by(study_id: context[:valid_q_params].study_id)

      assert question
      assert question.study_id == context[:valid_q_params].study_id
      assert question.questions == context[:valid_q_params].questions
      assert question.preposition == "post"
    end

    test "invalid parameters does not create a post study survey", context do
      post(context[:conn], "/api/survey/post/create", context[:invalid_q_params])

      question =
        SurveyQuestions.get_survey_question_by(study_id: context[:invalid_q_params].study_id)

      refute question
    end
  end

  describe "POST /api/survey/post/get" do
    test "valid parameters gets a post study survey", context do
      {:ok, question} =
        SurveyQuestions.create_survey_question(
          Map.put(context[:valid_q_params], :preposition, "post")
        )

      conn = post(context[:conn], "/api/survey/post/get", %{study_id: question.study_id})

      assert json_response(conn, 200) == %{
               "survey_question" => %{
                 "id" => question.id,
                 "preposition" => "post",
                 "questions" => ["q1", "q2", "q3"]
               }
             }
    end

    test "invalid parameters does not get a post study survey", context do
      conn = post(context[:conn], "/api/survey/post/get", %{study_id: 98_765_456_789})

      json_result = json_response(conn, 200)

      assert json_result == %{"survey_question" => nil}

      refute SurveyQuestions.get_survey_question_by(study_id: context[:invalid_q_params].study_id)
    end
  end

  describe "POST /api/survey/post/submit" do
    test "valid parameters submits an answer to post study survey", context do
      {:ok, question} =
        SurveyQuestions.create_survey_question(
          Map.put(context[:valid_q_params], :preposition, "post")
        )

      post(context[:conn], "/api/survey/post/submit", context[:valid_a_params])

      answer = SurveyAnswers.get_survey_answer_by(survey_question_id: question.id)

      assert answer
    end

    test "invalid parameters does not submit an answer to post study survey", context do
      {:ok, _question} =
        SurveyQuestions.create_survey_question(
          Map.put(context[:valid_q_params], :preposition, "post")
        )

      post(context[:conn], "/api/survey/post/submit", context[:invalid_a_params])

      answer = SurveyAnswers.get_survey_answer_by(answers: context[:invalid_a_params].answers)

      refute answer
    end
  end
end
