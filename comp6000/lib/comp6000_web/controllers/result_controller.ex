defmodule Comp6000Web.Study.ResultController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Tasks, Results, Storage}

  def append_data(
        conn,
        %{"task_id" => task_id, "uuid" => uuid, "data_type" => data_type, "content" => content} =
          _params
      ) do
    filetype =
      case data_type do
        "compile-data" -> :compile
        "replay-data" -> :replay
      end

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

    json(conn, %{
      String.to_atom("#{data_type}_appeneded") => Storage.append_data(result, content, filetype)
    })
  end

  def complete_data(
        conn,
        %{"task_id" => task_id, "data_type" => data_type, "uuid" => uuid} = _params
      ) do
    filetype =
      case data_type do
        "compile-data" -> :compile
        "replay-data" -> :replay
      end

    task = Tasks.get_task_by(id: task_id)

    result = Results.get_result_by(task_id: task_id, unique_participant_id: uuid)

    json(conn, %{
      String.to_atom("#{data_type}_completed") => Storage.complete_data(result, filetype)
    })
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

  def get_results(conn, %{"task_id" => task_id} = _params) do
    task = Tasks.get_task_by(id: task_id)

    json(conn, %{results: Results.get_results_for_task(task)})
  end
end
