defmodule Comp6000.Contexts.SurveyAnswers do
  alias Comp6000.Schemas.SurveyAnswer
  alias Comp6000.Repo

  def get_survey_answer_by(params) do
    case params[:id] do
      nil -> Repo.get_by(SurveyAnswer, params)
      id when is_integer(id) -> Repo.get_by(SurveyAnswer, params)
      _else -> nil
    end
  end

  def create_survey_answer(params \\ %{}) do
    %SurveyAnswer{}
    |> SurveyAnswer.changeset(params)
    |> Repo.insert()
  end
end
