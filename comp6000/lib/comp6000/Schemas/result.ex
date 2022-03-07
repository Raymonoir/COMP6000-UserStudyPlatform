defmodule Comp6000.Schemas.Result do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Result, Study}

  @derive {Jason.Encoder, only: [:unique_participant_id, :content, :id]}
  schema "result" do
    belongs_to(:study, Study)
    field(:unique_participant_id, :string)
    field(:content, :string)

    timestamps()
  end

  def changeset(%Result{} = result, params) do
    result
    |> cast(params, [:content, :unique_participant_id, :study_id])
    |> validate_required([:content, :study_id, :unique_participant_id])
    |> foreign_key_constraint(:study, name: :result_study_id_fkey)
  end
end
