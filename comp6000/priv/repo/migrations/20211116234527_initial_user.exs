defmodule Comp6000.Repo.Migrations.InitialUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add(:username, :string)
      add(:firstname, :string)
      add(:lastname, :string)
      add(:email, :string)
      add(:password_hash, :string)

      timestamps()
    end

    create(unique_index(:user, [:username]))
  end
end
