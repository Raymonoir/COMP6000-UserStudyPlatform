defmodule Comp6000.Schemas.Study do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Task, User, Study}

  @foreign_key_type :string
  schema "study" do
    belongs_to(:user, User, references: :username, foreign_key: :username)
    has_many(:task, Task)
    field(:title, :string)
    field(:task_count, :integer)

    timestamps()
  end

  def changeset(%Study{} = study, params) do
    study
    |> cast(params, [:title, :username, :task_count])
    |> validate_required([:title, :username])
    |> validate_length(:title, min: 4)
    |> foreign_key_constraint(:user, name: :study_username_fkey)
  end
end
