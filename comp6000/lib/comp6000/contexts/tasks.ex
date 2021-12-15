defmodule Comp6000.Contexts.Tasks do
  alias Comp6000.Repo
  alias Comp6000.Schemas.Task

  def get_task_by(params) do
    Repo.get_by(Task, params)
  end

  def create_task(params \\ %{}) do
    %Task{}
    |> Task.changeset(params)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, params) do
    Task.changeset(task, params)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end
end
