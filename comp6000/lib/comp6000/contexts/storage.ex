defmodule Comp6000.Contexts.Storage do
  alias Comp6000.Schemas.{Study, Task, Result}

  @storage_path Application.get_env(:comp6000, :storage_directory_path)
  @file_extension Application.get_env(:comp6000, :storage_file_extension)
  @completed_extension Application.get_env(:comp6000, :completed_file_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)

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

  def create_result_file(%Result{} = result) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path = "#{@storage_path}/#{study_id}/#{task_id}"

    if File.exists?(path) do
      case File.write("#{path}/#{result.unique_participant_id}.#{@file_extension}", "") do
        :ok ->
          :ok

        {:error, _reason} ->
          :error
      end
    else
      :error
    end
  end

  def append_result_file(%Result{} = result, chunk) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path =
      "#{@storage_path}/#{study_id}/#{task_id}/#{result.unique_participant_id}.#{@file_extension}"

    if File.exists?(path) do
      {:ok, current_content} = File.read(path)
      new_content = "#{current_content}#{@chunk_delimiter}#{chunk}"
      File.write(path, new_content)
    else
      :error
    end
  end

  def complete_file_storage(%Result{} = result) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path_no_ext = "#{@storage_path}/#{study_id}/#{task_id}/#{result.unique_participant_id}"

    if File.exists?("#{path_no_ext}.#{@file_extension}") do
      {:ok, content} = File.read("#{path_no_ext}.#{@file_extension}")
      gzipped_content = :zlib.gzip(content)
      File.write("#{path_no_ext}.#{@file_extension}", gzipped_content)

      :ok =
        File.rename("#{path_no_ext}.#{@file_extension}", "#{path_no_ext}.#{@completed_extension}")
    else
      :error
    end
  end

  def get_completed_file_content(%Result{} = result) do
    task = Comp6000.Contexts.Tasks.get_task_by(id: result.task_id)
    study_id = task.study_id
    task_id = task.id

    path =
      "#{@storage_path}/#{study_id}/#{task_id}/#{result.unique_participant_id}.#{@completed_extension}"

    if File.exists?(path) do
      {:ok, content} = File.read(path)
      :zlib.gunzip(content)
    else
      :error
    end
  end
end
