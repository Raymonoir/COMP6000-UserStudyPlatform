defmodule Comp6000.Repo.Migrations.StudyParticipation do
  use Ecto.Migration

  def change do
    alter table("study") do
      add(:participant_max, :integer)
      add(:participant_count, :integer)
      add(:participant_code, :string)
    end
  end
end
