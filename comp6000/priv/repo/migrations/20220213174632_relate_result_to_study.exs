defmodule Comp6000.Repo.Migrations.RelateResultToStudy do
  use Ecto.Migration

  def change do
    alter table("result") do
      add(:study_id, references(:study))
      remove(:task_id)
    end
  end
end
