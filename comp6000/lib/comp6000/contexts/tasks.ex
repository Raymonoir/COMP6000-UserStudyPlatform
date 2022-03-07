defmodule Comp6000.Contexts.Tasks do
  import Ecto.Query
  alias Comp6000.Repo
  alias Comp6000.Schemas.{Task, Study}
  alias Comp6000.Contexts.Storage

  def get_task_by(params) do
    case params[:id] do
      nil -> Repo.get_by(Task, params)
      id when is_integer(id) -> Repo.get_by(Task, params)
      _else -> nil
    end
  end

  def create_task(params \\ %{}) do
    %Task{}
    |> Task.changeset(params)
    |> Repo.insert()
  end

  def get_all_tasks_for_study(%Study{} = study) do
    query = from(t in Task, where: t.study_id == ^study.id)

    Repo.all(query) |> Repo.preload(:answer)
  end

  def update_task(%Task{} = task, params) do
    Task.changeset(task, params)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end
end
