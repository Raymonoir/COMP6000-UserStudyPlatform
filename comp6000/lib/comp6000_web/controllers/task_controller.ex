defmodule Comp6000Web.Task.TaskController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Tasks, Studies}

  def create(conn, %{"tasks" => tasks} = _params) do
    tasks =
      Enum.map(tasks, fn task ->
        case Tasks.create_task(task) do
          {:ok, created_task} ->
            created_task.id

          {:error, changeset} ->
            Helpers.get_changeset_errors(changeset)
        end
      end)

    json(conn, %{created_tasks: tasks})
  end

  def get(conn, %{"study_id" => study_id} = _params) do
    study = Studies.get_study_by(id: study_id)

    if study == nil do
      json(conn, %{tasks_for_study: nil})
    else
      all_studies = Tasks.get_all_tasks_for_study(study)
      json(conn, %{tasks_for_study: all_studies})
    end
  end

  def get(conn, %{"task_id" => task_id} = _params) do
    task = Tasks.get_task_by(id: task_id)

    if task == nil do
      json(conn, %{task: task})
    else
      json(conn, %{task: task})
    end
  end

  def edit(conn, %{"task_id" => task_id} = params) do
    task = Tasks.get_task_by(id: task_id)

    case Tasks.update_task(task, params) do
      {:ok, task} ->
        json(conn, %{updated_task: task.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def delete(conn, %{"task_id" => task_id} = _params) do
    task = Tasks.get_task_by(id: task_id)
    {:ok, task} = Tasks.delete_task(task)
    json(conn, %{deleted_task: task})
  end
end
