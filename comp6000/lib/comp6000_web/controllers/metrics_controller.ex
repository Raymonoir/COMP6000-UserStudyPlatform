defmodule Comp6000Web.Metrics.MetricsController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Metrics, Storage, Studies}
  alias Comp6000.ReplayMetrics.Calculations

  def get_current_metrics(conn, %{"study_id" => study_id}) do
    study = Studies.get_study_by(id: study_id)
    metrics_map = Calculations.get_average_study_metrics(study)

    json(conn, %{metrics_for_participant: metrics_map})
  end

  def get_metrics_for_participant(conn, %{"participant_uuid" => uuid}) do
    metrics = Metrics.get_metrics_by(participant_uuid: uuid)

    json(conn, %{metrics_for_participant: Jason.decode!(metrics.content)})
  end

  def get_metrics_for_study(conn, %{"study_id" => study_id}) do
    metrics =
      Metrics.get_metrics_by(participant_uuid: Integer.to_string(study_id), study_id: study_id)

    json(conn, %{metrics_for_study: Jason.decode!(metrics.content)})
  end

  def append_data(
        conn,
        %{
          "study_id" => study_id,
          "participant_uuid" => uuid,
          "data_type" => data_type,
          "content" => content
        } = _params
      ) do
    filetype =
      case data_type do
        "compile_data" -> :compile
        "replay_data" -> :replay
      end

    study = Studies.get_study_by(id: study_id)

    metrics = Metrics.get_metrics_by(participant_uuid: uuid, study_id: study.id)

    metrics =
      if metrics == nil do
        {:ok, metrics} =
          Metrics.create_metrics(%{
            participant_uuid: uuid,
            study_id: study.id,
            content: Jason.encode!(%{})
          })

        metrics
      else
        metrics
      end

    Storage.append_data(metrics, content, filetype)

    json(conn, %{
      String.to_atom("#{data_type}_appeneded") => uuid
    })
  end

  def complete_data(
        conn,
        %{
          "study_id" => study_id,
          "participant_uuid" => uuid
        } = _params
      ) do
    metrics = Metrics.get_metrics_by(study_id: study_id, participant_uuid: uuid)
    Storage.complete_data(metrics, :compile)
    Storage.complete_data(metrics, :replay)

    compile_metrics_map = Calculations.calculate_metrics(metrics, :compile)
    replay_metrics_map = Calculations.calculate_metrics(metrics, :replay)

    Metrics.update_metrics(metrics, %{
      content: Jason.encode!(%{compile: compile_metrics_map, replay: replay_metrics_map})
    })

    json(conn, %{String.to_atom("data_completed") => uuid})
  end
end
