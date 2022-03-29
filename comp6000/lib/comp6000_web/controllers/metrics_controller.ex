defmodule Comp6000Web.Metrics.MetricsController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Metrics, Storage, Studies, SurveyQuestions, SurveyAnswers}
  alias Comp6000.ReplayMetrics.Calculations

  def get_current_metrics(conn, %{"study_id" => study_id}) do
    study = Studies.get_study_by(id: study_id)
    metrics_map = Calculations.get_average_study_metrics(study)

    json(conn, %{metrics: metrics_map})
  end

  def get_metrics_for_participant(conn, %{"participant_uuid" => uuid}) do
    metrics = Metrics.get_metrics_by(participant_uuid: uuid)

    json(conn, %{metrics: Jason.decode!(metrics.content)})
  end

  def get_metrics_for_study(conn, %{"study_id" => study_id}) do
    metrics =
      Metrics.get_metrics_by(participant_uuid: Integer.to_string(study_id), study_id: study_id)

    json(conn, %{metrics: Jason.decode!(metrics.content)})
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

  def metrics_for_answers(
        conn,
        %{
          "study_id" => study_id,
          "preposition" => preposition,
          "question_pos" => q_pos,
          "type" => type
        } = _params
      ) do
    study = Studies.get_study_by(id: study_id)
    participants_list = study.participant_list

    survey_q =
      SurveyQuestions.get_survey_question_by(study_id: study_id, preposition: preposition)

    survey_q_list = survey_q.questions

    {question_map, _remainder} = List.pop_at(survey_q_list, q_pos)

    options_list = Jason.decode!(question_map)["options"]

    [head | tail] = participants_list

    options_metrics_list =
      Enum.reduce(options_list, [], fn option, acc ->
        acc ++
          [
            Enum.reduce(participants_list, [], fn participant, part_acc ->
              survey_a_list =
                SurveyAnswers.get_survey_answer_by(
                  participant_uuid: participant,
                  survey_question_id: survey_q.id
                ).answers

              {participant_answer, _remain} = List.pop_at(survey_a_list, q_pos)

              {val, _empty} = Integer.parse(participant_answer)
              {chosen, _remain} = List.pop_at(options_list, val)

              if chosen == option do
                metrics =
                  Metrics.get_metrics_by(study_id: study_id, participant_uuid: participant)

                part_acc ++ [metrics]
              else
                part_acc
              end
            end)
          ]
      end)

    if type == "full" do
      json(conn, %{metrics: options_metrics_list})
    else
      average_list =
        Enum.map(options_metrics_list, fn metrics_list ->
          Calculations.get_average_metrics(metrics_list, participants_list)
        end)

      json(conn, %{metrics: average_list})
    end
  end
end
