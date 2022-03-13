defmodule Comp6000.ReplayMetrics.Calculations do
  import Comp6000.Repo
  alias Comp6000.Contexts.Storage
  @storage_path Application.get_env(:comp6000, :storage_directory_path)
  @file_extension Application.get_env(:comp6000, :storage_file_extension)
  @completed_extension Application.get_env(:comp6000, :completed_file_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)

  def testing_data(datatype) do
    case datatype do
      :compile ->
        Jason.decode!(File.read!("test/support/code-examples/loop-arr-error-compile.txt"))

      :replay ->
        Jason.decode!(File.read!("test/support/code-examples/multi-chunk-replay.txt"))
    end
  end

  # def calculate_all(%Comp6000.Schemas.Study{} = study) do
  #   participants = study.participant_list

  #   Enum.reduce(participants, %{}, fn participant_uuid, acc ->
  #     []
  #   end)
  # end

  # def get_participant_data(participant_uuid, datatype) do
  #   {:ok, metrics} = Metrics.get_metric_by(participant_uuid)
  #   Jason.decode!(Storage.get_completed_data(metrics, datatype))
  # end

  def get_total_time(data_map_list) do
    first = List.first(data_map_list)
    last = List.last(data_map_list)

    first_datetime = convert_timestamp(first["start"])
    last_datetime = convert_timestamp(last["end"])
    elapsed = DateTime.diff(last_datetime, first_datetime, :second)
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

  def get_words_pasted(data_map_list) do
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
            chunk_acc + length(lines)
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
    end) - 1
  end

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

    Enum.reduce(Map.keys(error_map), {"", 0}, fn key, {acc_key, acc_val} ->
      if Map.get(error_map, key) > acc_val do
        {key, Map.get(error_map, key)}
      else
        {acc_key, acc_val}
      end
    end)
  end

  # def time_idle_proportion() do
  #   get_idle_time() / get_total_time(json_list)
  # end

  def get_times_run(data_map_list) do
    Enum.reduce(data_map_list, 0, fn data, acc ->
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
