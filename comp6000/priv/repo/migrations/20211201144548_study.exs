defmodule Comp6000.Repo.Migrations.Study do
  use Ecto.Migration

  def change do
    # I want to find out how good peoples multiplication is
    create table(:study) do
      add(:user, references(:user))
      add(:username, :string)
      add(:title, :string)
      add(:question_count, :int)

      timestamps()
    end

    # Task 1
    # What is 2 * 2?
    create table(:task) do
      add(:study_id, references(:study))
      add(:question_num, :int)
      add(:question_content, :string)
      add(:optional_info, :string)

      timestamps()
    end

    # I think 2 * 2 == 6
    create table(:result) do
      add(:task_id, references(:task))
      add(:unique_user_id, :string)
      add(:content, :string)

      timestamps()
    end

    # No I wanted: 2 * 2 == 4
    create table(:answer) do
      add(:task_id, references(:task))
      add(:content, :string)

      timestamps()
    end
  end
end
