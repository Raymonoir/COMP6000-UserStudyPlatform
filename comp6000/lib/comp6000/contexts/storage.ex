defmodule Comp6000.Contexts.Storage do
  alias Comp6000.Schemas.{Study, Task, Result}

  @storage_path Application.get_env(:comp6000, :storage_path)
  @extension Application.get_env(:comp6000, :extension)
  @completed_extension Application.get_env(:comp6000, :completed_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)
  @file_start Application.get_env(:comp6000, :file_start)
  @file_end Application.get_env(:comp6000, :file_end)
  @compile_filename Application.get_env(:comp6000, :compile_filename)
  @replay_filename Application.get_env(:comp6000, :compile_filename)

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

  def create_task_directory(%Task{} = task) do
    path = "#{@storage_path}/#{task.study_id}"

    if File.exists?(path) do
      case File.mkdir("#{path}/#{task.id}") do
        :ok ->
          :ok

        {:error, _reason} ->
          :error
      end
    else
      :error
    end
  end

  def delete_task_directory(%Task{} = task) do
    path = "#{@storage_path}/#{task.study_id}/#{task.id}"

    if File.exists?(path) do
      case File.rmdir(path) do
        :ok ->
          :ok

        {:error, _reason} ->
          :error
      end
    else
      :error
    end
  end

  def create_participant_directory(%Result{} = result) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path = "#{@storage_path}/#{study_id}/#{task_id}"

    if File.exists?(path) do
      case File.mkdir("#{path}/#{result.unique_participant_id}") do
        :ok ->
          result

        {:error, :eexist} ->
          result

        {:error, reason} ->
          {:error, reason}
      end
    else
      :error
    end
  end

  def create_participant_files(%Result{} = result) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    :ok =
      File.write(
        "#{get_participant_files_path(result, :replay)}.#{@extension}",
        @file_start
      )

    :ok =
      File.write(
        "#{get_participant_files_path(result, :compile)}.#{@extension}",
        @file_start
      )

    result
  end

  def append_data(%Result{} = result, chunk, filetype) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path = "#{get_participant_files_path(result, filetype)}.#{@extension}"

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

  def complete_data(%Result{} = result, filetype) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path_no_ext = "#{get_participant_files_path(result, filetype)}"

    if File.exists?("#{path_no_ext}.#{@extension}") do
      {:ok, content} = File.read("#{path_no_ext}.#{@extension}")
      gzipped_content = :zlib.gzip("#{content}#{@file_end}")
      File.write("#{path_no_ext}.#{@extension}", gzipped_content)

      :ok = File.rename("#{path_no_ext}.#{@extension}", "#{path_no_ext}.#{@completed_extension}")
    else
      :error
    end
  end

  def get_completed_data(%Result{} = result, filetype) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path = "#{get_participant_files_path(result, filetype)}.#{@completed_extension}"

    if File.exists?(path) do
      {:ok, content} = File.read(path)
      :zlib.gunzip(content)
    else
      :error
    end
  end

  defp get_participant_files_path(%Result{} = result, filetype) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    case filetype do
      :compile ->
        "#{@storage_path}/#{study_id}/#{task_id}/#{result.unique_participant_id}/#{@compile_filename}"

      :replay ->
        "#{@storage_path}/#{study_id}/#{task_id}/#{result.unique_participant_id}/#{@replay_filename}"
    end
  end
end
