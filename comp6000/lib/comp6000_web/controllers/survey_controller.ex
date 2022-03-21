defmodule Comp6000Web.Survey.SurveyController do
  use Comp6000Web, :controller
  import Plug.Conn
  alias Comp6000.Contexts.{SurveyQuestions, SurveyAnswers}

  def create_pre(conn, params) do
    case SurveyQuestions.create_survey_question(Map.put(params, "preposition", "pre")) do
      {:ok, survey_question} ->
        json(conn, %{created_survey_questions: survey_question.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def get_pre(conn, %{"study_id" => study_id} = _params) do
    question = SurveyQuestions.get_survey_question_by(study_id: study_id, preposition: "pre")
    json(conn, %{survey_question: question})
  end

  def submit_pre(conn, %{"study_id" => study_id} = params) do
    question_id = SurveyQuestions.get_survey_question_by(study_id: study_id).id

    case SurveyAnswers.create_survey_answer(Map.put(params, "survey_question_id", question_id)) do
      {:ok, survey_answer} ->
        json(conn, %{submitted_survey_answer: survey_answer.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def submit_pre(conn, _params) do
    json(conn, %{error: "invalid params"})
  end

  def create_post(conn, params) do
    case SurveyQuestions.create_survey_question(Map.put(params, "preposition", "post")) do
      {:ok, survey_question} ->
        json(conn, %{created_survey_questions: survey_question.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def get_post(conn, %{"study_id" => study_id} = _params) do
    question = SurveyQuestions.get_survey_question_by(study_id: study_id, preposition: "post")
    json(conn, %{survey_question: question})
  end

  def submit_post(conn, %{"study_id" => study_id} = params) do
    question_id = SurveyQuestions.get_survey_question_by(study_id: study_id).id

    case SurveyAnswers.create_survey_answer(Map.put(params, "survey_question_id", question_id)) do
      {:ok, survey_answer} ->
        json(conn, %{submitted_survey_answer: survey_answer.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def submit_post(conn, _params) do
    json(conn, %{error: "invalid params"})
  end
end
