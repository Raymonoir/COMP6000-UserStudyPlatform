defmodule Comp6000.Contexts.Results do
  import Ecto.Query
  alias Comp6000.Repo
  alias Comp6000.Schemas.{Result, Task}
  alias Comp6000.Contexts.{Storage, Tasks, Studies}

  def get_result_by(params) do
    Repo.get_by(Result, params)
  end

  def create_result(params \\ %{}) do
    case %Result{}
         |> Result.changeset(params)
         |> Repo.insert() do
      {:ok, result} ->
        result
        |> Storage.create_result_file()
        |> increment_participant_count()
        |> associate_participant_with_study()

        {:ok, result}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete_result(%Result{} = result) do
    Repo.delete(result)
  end

  def get_results_for_task(%Task{} = task) do
    Repo.preload(task, :results)
  end

  def get_result_for_task_uuid(task, uuid) do
    query = from(r in Result, where: r.task_id == ^task.id and r.unique_participant_id == ^uuid)

    Repo.all(query)
  end

  def associate_participant_with_study(%Result{} = result) do
    result
    |> get_study_for_result()
    |> Studies.add_participant(result.unique_participant_id)
  end

  def get_study_for_result(%Result{} = result) do
    task = Tasks.get_task_by(id: result.task_id)
    Studies.get_study_by(id: task.study_id)
  end

  def increment_participant_count(%Result{} = result) do
    {:ok, _study} = Studies.increment_participant_count(get_study_for_result(result))
    result
  end
end
