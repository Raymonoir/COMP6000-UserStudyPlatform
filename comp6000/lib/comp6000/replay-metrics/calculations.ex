defmodule Comp6000.ReplayMetrics.Calculations do
  import Comp6000.Repo
  alias Comp6000.Contexts.Storage
  @storage_path Application.get_env(:comp6000, :storage_directory_path)
  @file_extension Application.get_env(:comp6000, :storage_file_extension)
  @completed_extension Application.get_env(:comp6000, :completed_file_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)

  def get_replay_data(uuid, task_id) do
    result = Comp6000.Contexts.Result.get_result_by(id: task_id, unique_participant_id: uuid)

    Jason.decode!(Storage.get_completed_file_content(result))
  end

  def get_total_time(json_list) do
    first = List.first(json_list)
    last = List.last(json_list)

    first_datetime = convert_timestamp(first["start"])
    last_datetime = convert_timestamp(last["end"])
    elapsed = DateTime.diff(last_datetime, first_datetime, :second)
  end

  def words_deleted(json_list) do
  end

  def idle_time do
  end

  def times_compiled do
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
