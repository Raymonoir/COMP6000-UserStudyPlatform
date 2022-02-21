defmodule Comp6000.Schemas.SurveyAnswer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{SurveyAnswer, SurveyQuestion}

  @derive {Jason.Encoder, only: [:questions, :preposition]}
  schema "survey_answer" do
    belongs_to(:survey_question, SurveyQuestion)
    field(:participant_uuid, :string)
    field(:answers, {:array, :string})

    timestamps()
  end

  def changeset(%SurveyQuestion{} = survey_question, params) do
    survey_question
    |> cast(params, [:participant_uuid, :answers])
    |> validate_required([:participant_uuid, :answers])
    |> foreign_key_constraint(:study, name: :survey_answer_survey_question_id_fkey)
  end
end
