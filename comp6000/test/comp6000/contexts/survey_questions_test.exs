defmodule Comp6000.Contexts.SurveyQuestionsTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Studies, Users, SurveyQuestions}

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    valid_params = %{study_id: study.id, questions: ["q1", "q2", "q3"], preposition: "pre"}

    invalid_params = %{study_id: study.id, questions: ["q1", "q2", "q3"]}

    %{user: user, study: study, valid_params: valid_params, invalid_params: invalid_params}
  end

  describe "create_survey_questions" do
    test "valid parameters creates survey question", context do
      {:ok, question} = SurveyQuestions.create_survey_question(context[:valid_params])

      assert question.study_id == context[:valid_params].study_id
      assert question.questions == context[:valid_params].questions
      assert question.preposition == context[:valid_params].preposition
    end

    test "invalid parameters does not create question", context do
      {:error, _changeset} = SurveyQuestions.create_survey_question(context[:invalid_params])

      refute Repo.get_by(Comp6000.Schemas.SurveyQuestion,
               study_id: context[:invalid_params].study_id
             )
    end
  end

  describe "get_survey_question_by/1" do
    test "valid parameters return valid survey question", context do
      assert nil ==
               SurveyQuestions.get_survey_question_by(study_id: context[:valid_params].study_id)

      {:ok, survey_question} = SurveyQuestions.create_survey_question(context[:valid_params])

      assert survey_question ==
               SurveyQuestions.get_survey_question_by(study_id: context[:valid_params].study_id)

      assert survey_question ==
               SurveyQuestions.get_survey_question_by(questions: context[:valid_params].questions)

      assert survey_question ==
               SurveyQuestions.get_survey_question_by(
                 preposition: context[:valid_params].preposition
               )
    end
  end
end
