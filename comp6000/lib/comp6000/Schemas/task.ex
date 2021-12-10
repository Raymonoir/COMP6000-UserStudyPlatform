defmodule Comp6000.Schemas.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Study, Result, Answer, Task}

  # Content = the actual question the researcher is asking
  schema "task" do
    belongs_to(:study, Study)
    has_many(:results, Result)
    has_one(:answer, Answer)
    field(:task_number, :integer)
    field(:content, :string)
    field(:optional_info, :string)

    timestamps()
  end

  def changeset(%Task{} = task, params) do
    task
    |> cast(params, [:study_id, :task_number, :content, :optional_info])
    |> validate_required([:content, :task_number, :study_id, :answer])
    |> foreign_key_constraint(:study, name: :task_study_id_fkey)
  end
end
