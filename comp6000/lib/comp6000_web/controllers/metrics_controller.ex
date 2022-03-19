defmodule Comp6000Web.Metrics.MetricsController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Metrics, Storage, Studies}
  alias Comp6000.ReplayMetrics.Calculations

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

    metrics = Metrics.get_metrics_by(participant_uuid: uuid)

    metrics =
      if metrics == nil do
        {:ok, metrics} =
          Metrics.create_metrics(%{
            participant_uuid: uuid,
            study_id: study.id
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
          "participant_uuid" => uuid,
          "data_type" => data_type
        } = _params
      ) do
    filetype =
      case data_type do
        "compile_data" ->
          :compile

        "replay_data" ->
          :replay
      end

    metrics = Metrics.get_metrics_by(study_id: study_id, participant_uuid: uuid)

    Storage.complete_data(metrics, filetype)

    metrics_map = Calculations.calculate_metrics(metrics, filetype)

    Metrics.update_metrics(metrics, %{content: Jason.encode!(metrics_map)})

    json(conn, %{String.to_atom("#{data_type}_completed") => uuid})
  end
end
