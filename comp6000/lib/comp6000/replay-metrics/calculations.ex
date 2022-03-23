defmodule Comp6000.ReplayMetrics.Calculations do
  alias Comp6000.Contexts.{Storage, Metrics}

  def get_average_study_metrics(study) do
    study_participants = study.participant_list

    metrics_list =
      Enum.reduce(study_participants, [], fn participant_uuid, metrics_list ->
        metrics = Metrics.get_metrics_by(participant_uuid: participant_uuid, study_id: study.id)
        metrics_list ++ [metrics]
      end)

    # Replay bits
    total_replay_map =
      Enum.reduce(metrics_list, %{}, fn metric, metric_acc ->
        Enum.reduce(Jason.decode!(metric.content)["replay"], metric_acc, fn
          {k, v}, acc ->
            Map.put(acc, k, v + Map.get(acc, k, 0))
        end)
      end)

    average_replay_map =
      Enum.reduce(total_replay_map, %{}, fn {k, v}, acc ->
        Map.put(acc, k, v / length(study_participants))
      end)

    # Compile stuff
    total_compile_map =
      Enum.reduce(metrics_list, %{}, fn metric, metric_acc ->
        Enum.reduce(Jason.decode!(metric.content)["compile"], metric_acc, fn
          {"most_common_error", [mce, count]}, acc ->
            if mce != nil do
              mce_map = Map.get(acc, "most_common_error", %{})

              if Map.has_key?(Map.get(acc, "most_common_error", %{}), mce) do
                Map.put(
                  acc,
                  "most_common_error",
                  Map.put(mce_map, "most_common_error", Map.get(mce_map, "most_common_error"))
                )
              else
                Map.put(acc, "most_common_error", Map.merge(mce_map, Map.put(%{}, mce, count)))
              end
            end

          {k, v}, acc ->
            Map.put(acc, k, v + Map.get(acc, k, 0))
        end)
      end)

    average_compile_map =
      Enum.reduce(total_compile_map, %{}, fn
        {"most_common_error", mce_map}, acc_map ->
          list =
            Enum.reduce(acc_map, [], fn {k, v}, [acc_k, acc_v] ->
              if v > acc_v do
                [k, v]
              else
                [acc_k, acc_v]
              end
            end)

          Map.put(acc_map, "most_common_error", list)

        {k, v}, acc ->
          Map.put(acc, k, v / length(study_participants))
      end)

    %{compile_map: average_compile_map, replay_map: average_replay_map}
  end

  def calculate_metrics(metrics, filetype) do
    case filetype do
      :compile -> calculate_all_compile_metrics(metrics)
      :replay -> calculate_all_replay_metrics(metrics)
    end
  end

  def calculate_all_compile_metrics(metrics) do
    data = Storage.get_completed_data(metrics, :compile)

    %{}
    |> Map.put(:most_common_error, get_most_common_error(data, "UserCodeError"))
    |> Map.put(:times_compiled, get_times_run(data))
  end

  def calculate_all_replay_metrics(metrics) do
    data = Storage.get_completed_data(metrics, :replay)

    %{}
    |> Map.put(:total_time, get_total_time(data))
    |> Map.put(:insert_character_count, get_character_count(data, "insert"))
    |> Map.put(:remove_character_count, get_character_count(data, "remove"))
    |> Map.put(:idle_time, get_idle_time(data))
    |> Map.put(:pasted_character_count, get_characters_pasted(data))
    |> Map.put(:word_count, get_word_count(data))
    |> Map.put(:words_per_minute, get_words_per_minute(data))
    |> Map.put(:line_count, get_line_count(data))
  end

  def get_total_time(data_map_list) do
    first = List.first(data_map_list)
    last = List.last(data_map_list)

    first_datetime = convert_timestamp(first["start"])
    last_datetime = convert_timestamp(last["end"])

    DateTime.diff(last_datetime, first_datetime, :second)
  end

  # Action type = insert / remove
  def get_character_count(data_map_list, action_type) do
    Enum.reduce(data_map_list, 0, fn data_map, acc ->
      events = data_map["events"]

      acc +
        Enum.reduce(events, 0, fn [_time_added, keypress_data], acc ->
          action = Map.get(keypress_data, "action")

          if action == action_type do
            keys =
              Enum.reduce(Map.get(keypress_data, "lines"), fn data, acc ->
                acc <> data
              end)

            acc + String.length(keys)
          else
            acc
          end
        end)
    end)
  end

  def get_idle_time(data_map_list) do
    Enum.reduce(data_map_list, 0, fn data_map, acc ->
      events = data_map["events"]

      acc +
        Enum.reduce(events, 0, fn [time_added, _keypress], acc ->
          if time_added > 1000 do
            acc + time_added - 1000
          else
            acc
          end
        end)
    end) / 1000
  end

  def get_characters_pasted(data_map_list) do
    Enum.reduce(data_map_list, 0, fn data_map, acc ->
      acc +
        Enum.reduce(data_map["events"], 0, fn event, chunk_acc ->
          lines = List.last(event)["lines"]

          if lines not in [
               ["", ""],
               ["", "            ", "        }"],
               ["", "        ", "    }"],
               ["", "    ", "}"],
               ["", "        ", "    "]
             ] and length(lines) > 1 do
            chunk_acc + String.length(Enum.join(lines))
          else
            chunk_acc
          end
        end)
    end)
  end

  # def proportion_lines_pasted do
  #   get_line_count() / get_lines_pasted()
  # end

  # def get_inserted_charcters_proportion do
  #   get_character_count("insertion") /
  #     (get_character_count("insertion") +
  #        get_character_count("deletion"))
  # end

  def get_word_count(data_map_list) do
    Enum.reduce(data_map_list, 0, fn data_map, acc ->
      acc +
        Enum.reduce(data_map["events"], 0, fn event, chunk_acc ->
          lines = List.last(event)["lines"]

          if lines == [" "] do
            chunk_acc + 1
          else
            if length(lines) > 1 do
              chunk_acc + length(lines)
            else
              chunk_acc
            end
          end
        end)
    end)
  end

  # error_type: "UserCodeError"
  def get_most_common_error(data_map_list, error_type) do
    error_map =
      Enum.reduce(data_map_list, %{}, fn data, acc_map ->
        error = data[error_type]

        if Map.has_key?(acc_map, error) do
          Map.put(acc_map, error, Map.get(acc_map, error) + 1)
        else
          Map.put(acc_map, error, 1)
        end
      end)

    [mce, count] =
      Enum.reduce(Map.keys(error_map), ["", 0], fn key, [acc_key, acc_val] ->
        if Map.get(error_map, key) > acc_val do
          [key, Map.get(error_map, key)]
        else
          [acc_key, acc_val]
        end
      end)

    if mce == nil do
      ["no-error", 1]
    else
      [mce, count]
    end
  end

  # def time_idle_proportion() do
  #   get_idle_time() / get_total_time(json_list)
  # end

  def get_times_run(data_map_list) do
    Enum.reduce(data_map_list, 0, fn _data, acc ->
      acc + 1
    end)
  end

  # def proportion_passed() do
  #   {pass_count, fail_count} =
  #     Enum.reduce(content, fn data, {pass_count, fail_count} ->
  #       if data["passed"] do
  #         {pass_count + 1, fail_count}
  #       else
  #         {pass_count, fail_count + 1}
  #       end
  #     end)

  #   pass_count / (pass_count + fail_count)
  # end

  def get_words_per_minute(data_map_list) do
    time = get_total_time(data_map_list) / 60

    word_count = get_word_count(data_map_list)

    word_count / time
  end

  def get_line_count(data_map_list) do
    Enum.reduce(data_map_list, 0, fn data_map, acc ->
      max =
        Enum.reduce(data_map["events"], 0, fn [_time, map_event], chunk_acc ->
          if chunk_acc < map_event["end"]["row"] do
            map_event["end"]["row"]
          else
            chunk_acc
          end
        end)

      if acc < max do
        max
      else
        acc
      end
    end)
  end

  def convert_timestamp(unix_time) do
    DateTime.from_unix!(unix_time, :millisecond)
  end
end
