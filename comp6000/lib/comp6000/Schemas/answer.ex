defmodule Comp6000.Schemas.Answer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Task, Answer}

  @derive {Jason.Encoder, only: [:content, :id]}
  schema "answer" do
    belongs_to(:task, Task)
    field(:content, :string)

    timestamps()
  end

  def changeset(%Answer{} = answer, params) do
    answer
    |> cast(params, [:content, :task_id])
    |> validate_required([:content, :task_id])
    |> foreign_key_constraint(:task, name: :answer_task_id_fkey)
  end
end
