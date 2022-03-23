defmodule Comp6000.Contexts.Storage do
  alias Comp6000.Schemas.{Study, Task, Metrics}

  @storage_path Application.get_env(:comp6000, :storage_path)
  @extension Application.get_env(:comp6000, :extension)
  @completed_extension Application.get_env(:comp6000, :completed_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)
  @file_start Application.get_env(:comp6000, :file_start)
  @file_end Application.get_env(:comp6000, :file_end)
  @compile_filename Application.get_env(:comp6000, :compile_filename)
  @replay_filename Application.get_env(:comp6000, :replay_filename)

  def create_study_directory(%Study{} = study) do
    study_id = study.id

    path = "#{@storage_path}/#{study_id}"

    case File.mkdir(path) do
      :ok ->
        :ok

      {:error, _reason} ->
        :error
    end
  end

  def delete_study_directory(%Study{} = study) do
    study_id = study.id

    path = "#{@storage_path}/#{study_id}"

    case File.rmdir(path) do
      :ok ->
        :ok

      {:error, _reason} ->
        :error
    end
  end

  def create_participant_directory(%Metrics{} = metrics) do
    study_id = metrics.study_id

    path = "#{@storage_path}/#{study_id}"

    if File.exists?(path) do
      case File.mkdir("#{path}/#{metrics.participant_uuid}") do
        :ok ->
          metrics

        {:error, :eexist} ->
          metrics

        {:error, reason} ->
          {:error, reason}
      end
    else
      :file_no_exist
    end
  end

  def create_participant_files(%Metrics{} = metrics) do
    study_id = metrics.study_id

    :ok =
      File.write(
        "#{get_participant_files_path(metrics, :replay)}.#{@extension}",
        @file_start
      )

    :ok =
      File.write(
        "#{get_participant_files_path(metrics, :compile)}.#{@extension}",
        @file_start
      )

    metrics
  end

  def append_data(%Metrics{} = metrics, chunk, filetype) do
    study_id = metrics.study_id

    path = "#{get_participant_files_path(metrics, filetype)}.#{@extension}"

    if File.exists?(path) do
      {:ok, current_content} = File.read(path)

      new_content =
        if current_content == @file_start do
          "#{current_content}#{chunk}"
        else
          "#{current_content}#{@chunk_delimiter}#{chunk}"
        end

      File.write(path, new_content)
    end
  end

  def complete_data(%Metrics{} = metrics, filetype) do
    study_id = metrics.study_id

    path_no_ext = "#{get_participant_files_path(metrics, filetype)}"

    if File.exists?("#{path_no_ext}.#{@extension}") do
      {:ok, content} = File.read("#{path_no_ext}.#{@extension}")
      gzipped_content = :zlib.gzip("#{content}#{@file_end}")
      File.write("#{path_no_ext}.#{@extension}", gzipped_content)

      :ok = File.rename("#{path_no_ext}.#{@extension}", "#{path_no_ext}.#{@completed_extension}")
    else
      :file_no_exist
    end
  end

  def get_completed_data(%Metrics{} = metrics, filetype) do
    study_id = metrics.study_id

    path = "#{get_participant_files_path(metrics, filetype)}.#{@completed_extension}"

    if File.exists?(path) do
      {:ok, content} = File.read(path)
      Jason.decode!(:zlib.gunzip(content))
    else
      :file_no_exist
    end
  end

  defp get_participant_files_path(%Metrics{} = metrics, filetype) do
    study_id = metrics.study_id

    case filetype do
      :compile ->
        "#{@storage_path}/#{study_id}/#{metrics.participant_uuid}/#{@compile_filename}"

      :replay ->
        "#{@storage_path}/#{study_id}/#{metrics.participant_uuid}/#{@replay_filename}"
    end
  end
end
