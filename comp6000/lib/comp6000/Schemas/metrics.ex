defmodule Comp6000.Schemas.Metrics do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Study, Metrics}

  @derive {Jason.Encoder, only: [:unique_participant_id, :content, :id]}
  schema "metrics" do
    belongs_to(:study, Study)
    field(:participant_uuid, :string)
    field(:content, :string)

    timestamps()
  end

  def changeset(%Metrics{} = metrics, params) do
    metrics
    |> cast(params, [:content, :participant_uuid, :study_id])
    |> validate_required([:study_id, :participant_uuid])
    |> foreign_key_constraint(:study, name: :metrics_study_id_fkey)
  end
end
