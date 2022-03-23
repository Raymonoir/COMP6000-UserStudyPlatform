defmodule Comp6000.Contexts.Studies do
  import Ecto.Query
  alias Comp6000.Repo
  alias Comp6000.Schemas.{Study, User}
  alias Comp6000.Contexts.{Storage, Metrics}
  alias Comp6000.ReplayMetrics.Calculations

  def get_all_studies() do
    Repo.all(Study)
  end

  def get_study_by(params) do
    case params[:id] do
      nil -> Repo.get_by(Study, params)
      id when is_integer(id) -> Repo.get_by(Study, params)
      _else -> nil
    end
  end

  def create_study(params \\ %{}) do
    study = %Study{participant_code: UUID.uuid4()}

    case study
         |> Study.changeset(params)
         |> Repo.insert() do
      {:ok, study} ->
        Storage.create_study_directory(study)
        {:ok, study}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_study(%Study{} = study, params) do
    study
    |> Study.changeset(params)
    |> Repo.update()
  end

  def delete_study(%Study{} = study) do
    Repo.delete(study)
  end

  def add_participant(%Study{} = study, participant) do
    participants = study.participant_list

    if participant not in participants do
      {:ok, study} = update_study(study, %{participant_list: [participant | participants]})
      study
    else
      study
    end
  end

  def get_studies_for_user(%User{} = user) do
    query = from(s in Study, where: s.username == ^user.username)

    Repo.all(query)
  end

  def increment_participant_count(%Study{} = study) do
    if study.participant_count + 1 == study.participant_max do
      {:ok, study} =
        update_study(study, %{
          participant_count: study.participant_count + 1,
          participant_code: nil
        })

      metrics_map = Calculations.get_average_study_metrics(study)

      Metrics.create_metrics(%{
        content: Jason.encode!(metrics_map),
        participant_uuid: Integer.to_string(study.id),
        study_id: study.id
      })

      {:ok, study}
    else
      update_study(study, %{participant_count: study.participant_count + 1})
    end
  end

  def get_all_for_study(%Study{} = study) do
    Repo.preload(study, metrics: [], tasks: [:answer], user: [])
  end
end
