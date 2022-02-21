defmodule Comp6000.Contexts.SurveyQuestions do
  alias Comp6000.Schemas.SurveyQuestion

  def get_survey_question_by(params) do
    case params[:id] do
      nil -> Repo.get_by(SurveyQuestion, params)
      id when is_integer(id) -> Repo.get_by(SurveyQuestion, params)
      _else -> nil
    end
  end

  def create_survey_question(params \\ %{}) do
    %SurveyQuestion{}
    |> SurveyQuestion.changeset(params)
    |> Repo.insert()
  end
end
