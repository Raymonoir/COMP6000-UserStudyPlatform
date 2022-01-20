defmodule Comp6000Web.Study.ResultController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Tasks, Results, Storage}

  def append_replay_data(
        conn,
        %{"task_id" => task_id, "uuid" => uuid, "content" => content} = _params
      ) do
    task = Tasks.get_task_by(id: task_id)

    result = Results.get_result_by(task_id: task_id, unique_participant_id: uuid)

    result =
      if result == nil do
        {:ok, result} =
          Results.create_result(%{
            task_id: task_id,
            unique_participant_id: uuid,
            content: "placeholder"
          })

        result
      else
        result
      end

    json(conn, %{result_appeneded: Storage.append_result_file(result, content)})
  end

  def complete_replay_data(
        conn,
        %{"task_id" => task_id, "uuid" => uuid} = _params
      ) do
    task = Tasks.get_task_by(id: task_id)

    result = Results.get_result_by(task_id: task_id, unique_participant_id: uuid)

    json(conn, %{result_completed: Storage.complete_file_storage(result)})
  end

  def background_submit(
        conn,
        %{"study_id" => study_id, "uuid" => uuid, "content" => content} = _params
      ) do
    background_task = Tasks.get_task_by(study_id: study_id, optional_info: "background")

    results_map = %{unique_participant_id: uuid, task_id: background_task.id, content: content}

    {:ok, result} = Results.create_result(results_map)

    json(conn, %{background_result_created: result})
  end

  def background_submit(conn, params) do
    json(conn, %{invalid_background_parameters: params})
  end

  def result_submit(
        conn,
        %{"task_id" => task_id, "uuid" => uuid, "content" => content} = _params
      ) do
    results_map = %{unique_participant_id: uuid, task_id: task_id, content: content}

    {:ok, result} = Results.create_result(results_map)

    json(conn, %{result_created: result})
  end

  def result_submit(conn, params) do
    json(conn, %{invalid_result_parameters: params})
  end
end
