defmodule Comp6000.Schemas.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Study, Metrics, Answer, Task}

  @derive {Jason.Encoder, only: [:task_number, :content, :optional_info, :id, :answer]}
  # Content = the actual question the researcher is asking
  schema "task" do
    belongs_to(:study, Study)
    has_many(:metrics, Metrics)
    has_one(:answer, Answer)
    field(:task_number, :integer)
    field(:content, :string)
    field(:optional_info, :string)

    timestamps()
  end

  def changeset(%Task{} = task, params) do
    task
    |> cast(params, [:study_id, :task_number, :content, :optional_info])
    |> cast_assoc(:answer, with: &Answer.changeset/2)
    |> validate_required([:content, :study_id])
    |> foreign_key_constraint(:study, name: :task_study_id_fkey)
    |> update_task_number()
    |> update_study_task_count()
  end

  def update_task_number(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{study_id: study_id}} ->
        study = Comp6000.Contexts.Studies.get_study_by(id: study_id)

        if study != nil do
          current_count = study.task_count
          put_change(changeset, :task_number, current_count + 1)
        else
          changeset
        end

      _else ->
        changeset
    end
  end

  def update_study_task_count(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{study_id: study_id, task_number: task_number}} ->
        study = Comp6000.Contexts.Studies.get_study_by(id: study_id)

        if study != nil do
          Comp6000.Contexts.Studies.update_study(study, %{task_count: task_number})
        end

        changeset

      _else ->
        changeset
    end
  end
end
