defmodule Comp6000.Contexts.StorageTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Schemas.{Study, Task, Result}
  alias Comp6000.Contexts.{Storage, Users}

  @storage_path Application.get_env(:comp6000, :storage_path)
  @extension Application.get_env(:comp6000, :extension)
  @completed_extension Application.get_env(:comp6000, :completed_extension)
  @chunk_delimiter Application.get_env(:comp6000, :chunk_delimiter)
  @file_start Application.get_env(:comp6000, :file_start)
  @file_end Application.get_env(:comp6000, :file_end)
  @compile_filename Application.get_env(:comp6000, :compile_filename)
  @replay_filename Application.get_env(:comp6000, :compile_filename)

  # Use changeset and Repo directly to miss the use of Storage within the contexts
  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      %Study{}
      |> Study.changeset(%{username: user.username, title: "A Study Title", task_count: 0})
      |> Repo.insert()

    {:ok, task} =
      %Task{}
      |> Task.changeset(%{content: "What is 2*2?", task_number: 1, study_id: study.id})
      |> Repo.insert()

    {:ok, result} =
      %Result{}
      |> Result.changeset(%{
        task_id: task.id,
        unique_participant_id: "567f56d67s67as76d7s8",
        content: "3"
      })
      |> Repo.insert()

    %{study: study, task: task, result: result}
  end

  describe "create_study_directory/1" do
    test "creates a directory using a study", %{study: study} do
      :ok = Storage.create_study_directory(study)

      assert File.exists?("#{@storage_path}/#{study.id}")
    end
  end

  describe "delete_study_directory/1" do
    test "deletes a directory using a study", %{study: study} do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")

      assert File.exists?("#{@storage_path}/#{study.id}")

      :ok = Storage.delete_study_directory(study)

      refute File.exists?("#{@storage_path}/#{study.id}")
    end
  end

  describe "create_task_directory/1" do
    test "creates a directory using a task", %{study: study, task: task} do
      :ok = Storage.create_study_directory(study)
      assert File.exists?("#{@storage_path}/#{study.id}")

      :ok = Storage.create_task_directory(task)
      assert File.exists?("#{@storage_path}/#{study.id}/#{task.id}")
    end
  end

  describe "delete_task_directory/1" do
    test "deletes a directory using a task", %{study: study, task: task} do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")
      :ok = File.mkdir("#{@storage_path}/#{study.id}/#{task.id}")

      assert File.exists?("#{@storage_path}/#{study.id}/#{task.id}")

      :ok = Storage.delete_task_directory(task)

      refute File.exists?("#{@storage_path}/#{study.id}/#{task.id}")
    end
  end

  describe "create_participant_directory/1" do
    test "creates directory using a result", %{study: study, task: task, result: result} do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")
      :ok = File.mkdir("#{@storage_path}/#{study.id}/#{task.id}")

      assert result = Storage.create_participant_directory(result)

      path = "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}"

      assert File.exists?(path)
    end
  end

  describe "create_participant_files/1" do
    test "creates files at correct location", %{study: study, task: task, result: result} do
      create_all_dirs(study, task, result)

      assert result == Storage.create_participant_files(result)

      assert File.exists?(
               "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@compile_filename}.#{@extension}"
             )

      assert File.exists?(
               "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@replay_filename}.#{@extension}"
             )

      assert File.read!(
               "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@replay_filename}.#{@extension}"
             ) == @file_start

      assert File.read!(
               "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@compile_filename}.#{@extension}"
             ) == @file_start
    end
  end

  describe "append_data/3" do
    test "appends data to replay_data file", %{
      study: study,
      task: task,
      result: result
    } do
      create_all_dirs(study, task, result)

      path =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@replay_filename}.#{@extension}"

      :ok = File.write(path, @file_start)

      chunk1 = "chunk1data"
      chunk2 = "chunk2data"
      chunk3 = "chunk3data"

      :ok = Storage.append_data(result, chunk1, :replay)
      {:ok, "#{@file_start}chunk1data"} = File.read(path)

      :ok = Storage.append_data(result, chunk2, :replay)

      {:ok, "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data"} = File.read(path)

      :ok = Storage.append_data(result, chunk3, :replay)

      "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data#{@chunk_delimiter}chunk3data" =
        File.read!(path)
    end

    test "appends data to compile_data file", %{
      study: study,
      task: task,
      result: result
    } do
      create_all_dirs(study, task, result)

      path =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@compile_filename}.#{@extension}"

      :ok = File.write(path, @file_start)

      chunk1 = "chunk1data"
      chunk2 = "chunk2data"
      chunk3 = "chunk3data"

      :ok = Storage.append_data(result, chunk1, :compile)
      {:ok, "#{@file_start}chunk1data"} = File.read(path)

      :ok = Storage.append_data(result, chunk2, :compile)

      {:ok, "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data"} = File.read(path)

      :ok = Storage.append_data(result, chunk3, :compile)

      "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data#{@chunk_delimiter}chunk3data" =
        File.read!(path)
    end
  end

  describe "complete_data/2" do
    test "gzips content and renames replay_data file with .gzip file extension", %{
      study: study,
      task: task,
      result: result
    } do
      create_all_dirs(study, task, result)

      path_no_ext =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@replay_filename}"

      unzipped_content = "#{@file_start}A few chunks"
      :ok = File.write("#{path_no_ext}.#{@extension}", unzipped_content)

      :ok = Storage.complete_data(result, :replay)

      assert File.exists?("#{path_no_ext}.#{@completed_extension}")

      refute File.exists?("#{path_no_ext}.#{@extension}")

      {:ok, gzipped_content} = File.read("#{path_no_ext}.#{@completed_extension}")

      result = :zlib.gunzip(gzipped_content)
      assert result == "#{unzipped_content}#{@file_end}"
    end

    test "gzips content and renames compile_data file with .gzip file extension", %{
      study: study,
      task: task,
      result: result
    } do
      create_all_dirs(study, task, result)

      path_no_ext =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@compile_filename}"

      unzipped_content = "#{@file_start}A few chunks"
      :ok = File.write("#{path_no_ext}.#{@extension}", unzipped_content)

      :ok = Storage.complete_data(result, :compile)

      assert File.exists?("#{path_no_ext}.#{@completed_extension}")

      refute File.exists?("#{path_no_ext}.#{@extension}")

      {:ok, gzipped_content} = File.read("#{path_no_ext}.#{@completed_extension}")

      result = :zlib.gunzip(gzipped_content)
      assert result == "#{unzipped_content}#{@file_end}"
    end
  end

  describe "get_completed_data/2" do
    test "returns content stored in completed replay_data file", %{
      study: study,
      task: task,
      result: result
    } do
      create_all_dirs(study, task, result)

      path =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@replay_filename}.#{@completed_extension}"

      unzipped_content = "A few chunks"
      gzipped_content = :zlib.gzip(unzipped_content)
      :ok = File.write(path, gzipped_content)

      assert unzipped_content == Storage.get_completed_data(result, :replay)
    end

    test "returns content stored in completed compile_data file", %{
      study: study,
      task: task,
      result: result
    } do
      create_all_dirs(study, task, result)

      path =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}/#{@compile_filename}.#{@completed_extension}"

      unzipped_content = "A few chunks"
      gzipped_content = :zlib.gzip(unzipped_content)
      :ok = File.write(path, gzipped_content)

      assert unzipped_content == Storage.get_completed_data(result, :compile)
    end
  end

  def create_all_dirs(study, task, result) do
    File.mkdir!("#{@storage_path}/#{study.id}")
    File.mkdir!("#{@storage_path}/#{study.id}/#{task.id}")
    File.mkdir!("#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}")
  end
end
