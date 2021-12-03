defmodule Comp6000.Repo.Migrations.InitialStudy do
  use Ecto.Migration

  def change do
    # I want to find out how good peoples multiplication is
    create table(:study) do
      add(:username, references(:user, column: :username, type: :string))
      add(:title, :string)
      add(:task_count, :int)

      timestamps()
    end

    create(unique_index(:study, [:id]))

    # Task 1
    # What is 2 * 2?
    create table(:task) do
      add(:study_id, references(:study))
      add(:task_number, :int)
      add(:content, :string)
      add(:optional_info, :string)

      timestamps()
    end

    create(unique_index(:task, [:id]))

    # One persons answer: I think 2 * 2 == 6
    create table(:result) do
      add(:task_id, references(:task))
      add(:unique_participant_id, :string)
      add(:content, :string)

      timestamps()
    end

    create(unique_index(:result, [:id]))

    # The answer the researcher was looking for: I  wanted: 2 * 2 == 4
    create table(:answer) do
      add(:task_id, references(:task))
      add(:content, :string)

      timestamps()
    end

    create(unique_index(:answer, [:id]))
  end
end
