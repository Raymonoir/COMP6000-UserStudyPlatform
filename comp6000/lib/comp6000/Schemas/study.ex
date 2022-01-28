defmodule Comp6000.Schemas.Study do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Task, User, Study}

  @derive {Jason.Encoder,
           only: [
             :id,
             :username,
             :title,
             :task_count,
             :tasks,
             :participant_count,
             :participant_max,
             :participant_code
           ]}
  @foreign_key_type :string
  schema "study" do
    belongs_to(:user, User, references: :username, foreign_key: :username)
    has_many(:tasks, Task)
    field(:title, :string)
    field(:task_count, :integer, default: 0)
    field(:participant_count, :integer, default: 0)
    field(:participant_max, :integer)
    field(:participant_code, :string)
    field(:participant_list, {:array, :string}, default: [])

    timestamps()
  end

  def changeset(%Study{} = study, params) do
    study
    |> cast(params, [
      :title,
      :username,
      :task_count,
      :participant_count,
      :participant_max,
      :participant_code,
      :participant_list
    ])
    |> cast_assoc(:tasks, with: &Task.changeset/2)
    |> validate_required([:title, :username, :task_count])
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:title, min: 4, max: 200)
    |> foreign_key_constraint(:user, name: :study_username_fkey)
  end
end
