defmodule Comp6000.Contexts.Tasks do
  import Ecto.Query
  alias Comp6000.Repo
  alias Comp6000.Schemas.{Task, Study}
  alias Comp6000.Contexts.Storage

  def get_task_by(params) do
    Repo.get_by(Task, params)
  end

  def create_task(params \\ %{}) do
    case %Task{}
         |> Task.changeset(params)
         |> Repo.insert() do
      {:ok, task} ->
        Storage.create_task_directory(task)
        {:ok, task}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_all_tasks_for_study(%Study{} = study) do
    query = from(t in Task, where: t.study_id == ^study.id)

    Repo.all(query)
  end

  def update_task(%Task{} = task, params) do
    Task.changeset(task, params)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end
end
