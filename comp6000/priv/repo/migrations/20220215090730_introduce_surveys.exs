defmodule Comp6000.Repo.Migrations.IntroduceSurveys do
  use Ecto.Migration

  def change do
    create table(:survey_question) do
      add(:study_id, references(:study))
      add(:questions, {:array, :string})
      # Pre or post survey
      add(:preposition, :string)

      timestamps()
    end

    create table(:survey_answer) do
      add(:survey_question_id, references(:survey_question))
      add(:participant_uuid, :string)
      add(:answers, {:array, :string})

      timestamps()
    end
  end
end
