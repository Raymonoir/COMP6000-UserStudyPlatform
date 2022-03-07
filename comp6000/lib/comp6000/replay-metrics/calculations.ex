defmodule Comp6000.ReplayMetrics.Calculations do
  import Comp6000.Repo
  alias Comp6000.Contexts.Storage
  @storage_path Application.get_env(:comp6000, :storage_directory_path)
  @file_extension Application.get_env(:comp6000, :storage_file_extension)
  @completed_extension Application.get_env(:comp6000, :completed_file_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)

  def calculate_all(Comp6000.Schemas.Study{} = study) do
    participants = study.participant_list

    Enum.reduce(participants, %{}. fn participant_uuid, acc ->

    end)
  end

  def get_participant_data(participant_uuid, datatype) do


    Jason.decode!(Storage.get_completed_file_content(result))
  end

  def get_total_time(json_list) do
    first = List.first(json_list)
    last = List.last(json_list)

    first_datetime = convert_timestamp(first["start"])
    last_datetime = convert_timestamp(last["end"])
    elapsed = DateTime.diff(last_datetime, first_datetime, :second)
  end

  def character_count(json_list, action_type) do
    events = content["events"]

    Map.reduce(events, 0, fn [_time_added, keypress_data], acc ->
      action = Map.get(keypress_data, "action")

      if action == action_type do
        keys =
          Enum.reduce(Map.get(keypress_data, "lines"), fn data, acc ->
            acc <> data
          end)

        String.length(keys)
      else
        acc
      end
    end)
  end

  def idle_time(json) do
    events = content["events"]

    Map.reduce(events, 0, fn [time_added, _keypress], acc ->
      if time_added > 1000 do
        acc + time_added - 1000
      else
        acc
      end
    end)
  end

  def get_lines_pasted(json_list) do
    Enum.reduce(json_list, 0, fn chunk, acc ->
      acc +
        Enum.reduce(chunk["events"], 0, fn event, chunk_acc ->
          lines = List.last(event)["lines"]

          if lines != ["", ""] and length(lines) > 1 do
            chunk_acc + length(lines)
          else
            chunk_acc
          end
        end)
    end)
  end

  def proportion_lines_pasted do
    get_line_count() / get_lines_pasted()
  end

  def get_inserted_charcters_proportion do
    get_character_count("insertion") /
      (get_character_count("insertion") +
         get_character_count("deletion"))
  end

  def word_count(json_list) do
    Enum.reduce(json_list, 0, fn chunk, acc ->
      acc +
        Enum.reduce(chunk["events"], 1, fn event, chunk_acc ->
          lines = List.last(event)["lines"]

          if lines == [" "] do
            chunk_acc + 1
          else
            if length(lines) > 1 do
              chunk_acc +
                Enum.reduce(lines, 0, fn line, line_acc ->
                  line_acc + length(String.split(line))
                end)
            else
              chunk_acc
            end
          end
        end)
    end)
  end

  def most_common_error(json_list, error_type) do
    error_map = %{}

    Enum.each(content, fn data ->
      error = data[error_type]

      if Map.has_key?(error_map, error) do
        Map.put(error_map, error, Map.get(error_map, error) + 1)
      else
        Map.put(error_map, error, 1)
      end
    end)

    Enum.reduce(Map.keys(error_map), fn key, {acc_key, acc_val} ->
      if Map.get(error_map, key) > acc_val do
        {key, Map.get(error_map, key)}
      else
        {acc_key, acc_val}
      end
    end)
  end

  def time_idle_proportion() do
    get_idle_time() / get_total_time(json_list)
  end

  def times_run() do
    Enum.reduce(content, fn data, acc ->
      acc + 1
    end)
  end

  def proportion_passed() do
    {pass_count, fail_count} =
      Enum.reduce(content, fn data, {pass_count, fail_count} ->
        if data["passed"] do
          {pass_count + 1, fail_count}
        else
          {pass_count, fail_count + 1}
        end
      end)

    pass_count / (pass_count + fail_count)
  end

  def words_per_minute(json_list) do
    time = get_total_time(json_list)

    word_count = word_count(json_list)

    round(word_count / time)
  end

  def get_line_count(json_list) do
    Enum.reduce(json_list, 0, fn chunk, acc ->
      acc +
        Enum.reduce(chunk["events"], 0, fn event, chunk_acc ->
          lines = List.last(event)["lines"]

          if lines == ["", ""] do
            chunk_acc + 1
          else
            chunk_acc
          end
        end)
    end)
  end

  def json_testing() do
    Jason.decode!(File.read!("lib/comp6000/replay-metrics/chunk.json"))
  end

  def convert_timestamp(unix_time) do
    DateTime.from_unix!(unix_time, :millisecond)
  end
end
