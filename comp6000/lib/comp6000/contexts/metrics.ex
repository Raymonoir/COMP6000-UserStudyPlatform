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

  # def create_result(params \\ %{}) do
  #   case %Result{}
  #        |> Result.changeset(params)
  #        |> Repo.insert() do
  #     {:ok, result} ->
  #       result
  #       |> Storage.create_participant_directory()
  #       |> Storage.create_participant_files()
  #       |> increment_participant_count()
  #       |> associate_participant_with_study()

  #       {:ok, result}

  #     {:error, changeset} ->
  #       {:error, changeset}
  #   end
  # end

  # def delete_result(%Result{} = result) do
  #   Repo.delete(result)
  # end

  # def get_results_for_task(%Task{} = task) do
  #   Repo.preload(task, :results).results
  # end

  # def get_all_results_for_uuid(uuid) do
  #   query = from(r in Result, where: r.unique_participant_id == ^uuid)

  #   Repo.all(query)
  # end

  # def get_result_for_study_uuid(study, uuid) do
  #   query = from(r in Result, where: r.study_id == ^study.id and r.unique_participant_id == ^uuid)

  #   Repo.all(query)
  # end

  # def associate_participant_with_study(%Result{} = result) do
  #   result
  #   |> get_study_for_result()
  #   |> Studies.add_participant(result.unique_participant_id)
  # end

  # def get_study_for_result(%Result{} = result) do
  #   Studies.get_study_by(id: result.study_id)
  # end

  # def increment_participant_count(%Result{} = result) do
  #   {:ok, _study} = Studies.increment_participant_count(get_study_for_result(result))
  #   result
  # end
end
