defmodule Comp6000.Contexts.SurveyAnswersTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Studies, Users, SurveyQuestions, SurveyAnswers}

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, survey_question} =
      SurveyQuestions.create_survey_question(%{
        study_id: study.id,
        questions: ["q1", "q2", "q3"],
        preposition: "pre"
      })

    valid_params = %{
      survey_question_id: survey_question.id,
      answers: ["a1", "a2", "a3"],
      participant_uuid: "uuidv4"
    }

    invalid_params = %{
      survey_question_id: survey_question.id,
      answers: ["a1", "a2", "a3"]
    }

    %{
      user: user,
      study: study,
      survey_question: survey_question,
      valid_params: valid_params,
      invalid_params: invalid_params
    }
  end

  describe "create_survey_answer" do
    test "valid parameters creates survey answer", context do
      {:ok, answer} = SurveyAnswers.create_survey_answer(context[:valid_params])

      assert answer.survey_question_id == context[:valid_params].survey_question_id
      assert answer.answers == context[:valid_params].answers
      assert answer.participant_uuid == context[:valid_params].participant_uuid
    end

    test "invalid parameters does not create answer", context do
      {:error, _changeset} = SurveyAnswers.create_survey_answer(context[:invalid_params])

      refute Repo.get_by(Comp6000.Schemas.SurveyAnswer,
               survey_question_id: context[:invalid_params].survey_question_id
             )
    end
  end

  describe "create_survey_answer_by/1" do
    test "valid parameters return valid survey answer", context do
      assert nil ==
               SurveyAnswers.get_survey_answer_by(
                 survey_question_id: context[:valid_params].survey_question_id
               )

      {:ok, survey_answer} = SurveyAnswers.create_survey_answer(context[:valid_params])

      assert survey_answer ==
               SurveyAnswers.get_survey_answer_by(
                 survey_question_id: context[:valid_params].survey_question_id
               )

      assert survey_answer ==
               SurveyAnswers.get_survey_answer_by(answers: context[:valid_params].answers)

      assert survey_answer ==
               SurveyAnswers.get_survey_answer_by(
                 participant_uuid: context[:valid_params].participant_uuid
               )
    end
  end
end
