defmodule Comp6000.Schemas.SurveyQuestion do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{SurveyQuestion, Study}

  @derive {Jason.Encoder, only: [:id, :questions, :preposition]}
  schema "survey_question" do
    belongs_to(:study, Study)
    field(:questions, {:array, :string})
    field(:preposition, :string)

    timestamps()
  end

  def changeset(%SurveyQuestion{} = survey_question, params) do
    survey_question
    |> cast(params, [:study_id, :questions, :preposition])
    |> validate_required([:preposition, :questions, :study_id])
    |> foreign_key_constraint(:study, name: :survey_question_study_id_fkey)
  end
end
