defmodule Comp6000.Schemas.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Study, Result, Answer}

  #Content = the actual question the researcher is asking
  schema "task" do
    belongs_to(:study, Study)
    has_many(:result, Result)
    has_one(:answer, Answer)
    field(:task_number, :integer)
    field(:content, :string)
    field(:optional_info, :string)

    timestamps()
  end


  def changeset(%Task{} = task, params) do
    task
    |> cast(params, [:study_id, :result_id, :answer, :task_number, :content, :optional_info])
    |> validate_required([:content, :task_number])
    |> assoc_constraint(:study)
  end
end
