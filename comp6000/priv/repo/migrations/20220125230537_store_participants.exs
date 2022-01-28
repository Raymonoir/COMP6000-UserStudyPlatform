defmodule Comp6000.Repo.Migrations.StoreParticipants do
  use Ecto.Migration

  def change do
    alter table("study") do
      add(:participant_list, {:array, :string})
    end
  end
end
