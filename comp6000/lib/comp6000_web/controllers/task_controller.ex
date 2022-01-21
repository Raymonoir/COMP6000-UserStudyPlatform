defmodule Comp6000Web.Study.TaskController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Tasks, Storage, Studies}

  def create(conn, params) do
    case Tasks.create_task(params) do
      {:ok, task} ->
        json(conn, %{created_task: task.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def get_tasks(conn, %{"study_id" => study_id} = _params) do
    study = Studies.get_study_by(id: study_id)

    if study == nil do
      json(conn, %{invalid_study: []})
    else
      all_studies = Tasks.get_all_tasks_for_study(study)
      json(conn, %{tasks_for_study: all_studies})
    end
  end
end
