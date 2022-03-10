defmodule Comp6000.Contexts.Metrics do
  import Ecto.Query
  alias Comp6000.Repo
  alias Comp6000.Schemas.{Metrics, Task}
  alias Comp6000.Contexts.{Storage, Tasks, Studies}

  def get_metrics_by(params) do
    case params[:id] do
      nil -> Repo.get_by(Metrics, params)
      id when is_integer(id) -> Repo.get_by(Metrics, params)
      _else -> nil
    end
  end

  def create_metrics(params \\ %{}) do
    case %Metrics{}
         |> Metrics.changeset(params)
         |> Repo.insert() do
      {:ok, metrics} ->
        metrics
        |> Storage.create_participant_directory()
        |> Storage.create_participant_files()
        |> increment_participant_count()
        |> associate_participant_with_study()

        {:ok, metrics}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete_result(%Metrics{} = metrics) do
    Repo.delete(metrics)
  end

  def get_metrics_for_study(study, uuid) do
    query = from(m in Metrics, where: m.study_id == ^study.id and m.participant_uuid == ^uuid)

    Repo.all(query)
  end

  def associate_participant_with_study(%Metrics{} = metrics) do
    metrics
    |> get_study_for_metrics()
    |> Studies.add_participant(metrics.participant_uuid)
  end

  def get_study_for_metrics(%Metrics{} = metrics) do
    Studies.get_study_by(id: metrics.study_id)
  end

  def increment_participant_count(%Metrics{} = metrics) do
    {:ok, _study} = Studies.increment_participant_count(get_study_for_metrics(metrics))
    metrics
  end
end
