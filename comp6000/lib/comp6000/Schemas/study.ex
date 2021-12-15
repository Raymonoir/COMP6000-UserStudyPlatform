defmodule Comp6000.Schemas.Study do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Task, User, Study}

  @foreign_key_type :string
  schema "study" do
    belongs_to(:user, User, references: :username, foreign_key: :username)
    has_many(:tasks, Task)
    field(:title, :string)
    field(:task_count, :integer, default: 0)

    timestamps()
  end

  def changeset(%Study{} = study, params) do
    study
    |> cast(params, [:title, :username, :task_count])
    |> cast_assoc(:tasks, with: &Task.changeset/2)
    |> validate_required([:title, :username, :task_count])
    |> validate_changeset()
  end

  def update_changeset(%Study{} = study, params) do
    study
    |> cast(params, [:title, :username, :task_count])
    |> cast_assoc(:tasks)
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:title, min: 4, max: 200)
    |> foreign_key_constraint(:user, name: :study_username_fkey)
  end
end
