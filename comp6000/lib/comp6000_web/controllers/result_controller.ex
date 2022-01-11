defmodule Comp6000Web.ResultController do
  use Comp6000Web, :controller

  def append_code(conn, params) do
  end

  def complete_code(conn, params) do
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

  def result_submit(
        conn,
        %{"task_id" => task_id, "uuid" => uuid, "content" => content} = _params
      ) do
    results_map = %{unique_participant_id: uuid, task_id: task_id, content: content}

    {:ok, result} = Results.create_result(results_map)

    json(conn, %{result_created: result})
  end
end
