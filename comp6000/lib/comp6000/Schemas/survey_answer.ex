defmodule Comp6000.Schemas.SurveyAnswer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{SurveyAnswer, SurveyQuestion}

  @derive {Jason.Encoder, only: [:id, :answers, :participant_uuid]}
  schema "survey_answer" do
    belongs_to(:survey_question, SurveyQuestion)
    field(:participant_uuid, :string)
    field(:answers, {:array, :string})

    timestamps()
  end

  def changeset(%SurveyAnswer{} = survey_answer, params) do
    survey_answer
    |> cast(params, [:survey_question_id, :participant_uuid, :answers])
    |> validate_required([:participant_uuid, :answers, :survey_question_id])
    |> foreign_key_constraint(:study, name: :survey_answer_survey_question_id_fkey)
  end
end
