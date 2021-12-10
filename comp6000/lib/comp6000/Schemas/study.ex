defmodule Comp6000.Schemas.Study do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Task, User}

  @foreign_key_type :string
  schema "study" do
    belongs_to(:user, User, references: :username, foreign_key: :username)
    has_many(:task, Task)
    field(:title, :string)
    field(:task_count, :integer)

    timestamps()
  end

  def changeset(study, params \\ %{}) do
    study
    |> cast(params, [:title, :username])
    |> cast_required([:title])
    |> foreign_key_constraint(:user, name: :study_username_fkey)
  end
end
