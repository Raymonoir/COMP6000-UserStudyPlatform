defmodule Comp6000.Contexts.Storage do
  alias Comp6000.Schemas.Study

  @storage_path Application.get_env(:comp6000, :storage_directory_path)

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

  def create_task_directory(task) do
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

  def delete_task_directory(task) do
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
end
