defmodule Comp6000Web.StudyController do
  use Comp6000Web, :controller
  import Plug.Conn
  alias Comp6000.Contexts.{Storage, Studies, Tasks, Results}

  def create(conn, params) do
    case Studies.create_study(params) do
      {:ok, study} ->
        Storage.create_study_directory(study)
        json(conn, %{created_study: study.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def background_submit(
        conn,
        %{"study_id" => study_id, "uuid" => uuid, "content" => content} = _params
      ) do
    # Create and save answers related to tasks that will be the background check answers
    background_task = Tasks.get_task_by(study_id: study_id, optional_info: "background")

    results_map = %{unique_participant_id: uuid, task_id: background_task.id, content: content}

    {:ok, result} = Results.create_result(results_map)

    json(conn, %{background_result_created: result})
  end

  def result_submit(
        conn,
        %{"task_id" => task_id, "uuid" => uuid, "content" => content} = _params
      ) do
    results_map = %{unique_participant_id: uuid, task_id: task_id, content: content}

    {:ok, result} = Results.create_result(results_map)

    json(conn, %{result_created: result})
  end

  def get_tasks(conn, %{"study_id" => study_id} = _params) do
    study = Studies.get_study_by(id: study_id)
    all_studies = Tasks.get_all_tasks_for_study(study)
    json(conn, %{tasks_for_study: all_studies})
  end
end
