defmodule Comp6000.Schemas.Result do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Result, Task}

  @derive {Jason.Encoder, only: [:unique_participant_id, :content, :id]}
  schema "result" do
    belongs_to(:task, Task)
    field(:unique_participant_id, :string)
    field(:content, :string)

    timestamps()
  end

  def changeset(%Result{} = result, params) do
    result
    |> cast(params, [:content, :unique_participant_id, :task_id])
    |> validate_required([:content, :task_id, :unique_participant_id])
    |> foreign_key_constraint(:task, name: :answer_task_id_fkey)
  end
end
