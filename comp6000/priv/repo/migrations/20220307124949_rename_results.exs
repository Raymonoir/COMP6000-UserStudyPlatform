defmodule Comp6000.Repo.Migrations.RenameResults do
  use Ecto.Migration

  def change do
    drop(table("result"))

    create table(:metrics) do
      add(:study_id, references(:study))
      add(:participant_uuid, :string)
      add(:content, :text)

      timestamps()
    end
  end
end
