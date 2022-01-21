defmodule Comp6000.Repo.Migrations.IncreaseContentSize do
  use Ecto.Migration

  def change do
    alter table("task") do
      modify(:content, :text)
    end

    alter table("result") do
      modify(:content, :text)
    end

    alter table("answer") do
      modify(:content, :text)
    end
  end
end
