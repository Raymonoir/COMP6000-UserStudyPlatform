defmodule Comp6000.Contexts.StorageTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Storage, Studies, Users, Tasks, Results}

  @storage_path Application.get_env(:comp6000, :storage_directory_path)
  @file_extension Application.get_env(:comp6000, :storage_file_extension)
  @completed_extension Application.get_env(:comp6000, :completed_file_extension)

  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, task} =
      Tasks.create_task(%{content: "What is 2*2?", task_number: 1, study_id: study.id})

    {:ok, result} =
      Results.create_result(%{
        task_id: task.id,
        unique_participant_id: "567f56d67s67as76d7s8",
        content: "3"
      })

    on_exit(&clear_local_storage/0)

    %{study: study, task: task, result: result}
  end

  # An exceedingly nasty function to delete all files and directories within local-storage once tests are complete
  defp clear_local_storage() do
    Enum.map(File.ls!("#{@storage_path}"), fn study_dir ->
      if File.dir?("#{@storage_path}/#{study_dir}") do
        Enum.map(File.ls!("#{@storage_path}/#{study_dir}"), fn task_dir ->
          Enum.map(File.ls!("#{@storage_path}/#{study_dir}/#{task_dir}"), fn file ->
            File.rm("#{@storage_path}/#{study_dir}/#{task_dir}/#{file}")
          end)

          File.rmdir!("#{@storage_path}/#{study_dir}/#{task_dir}")
        end)

        File.rmdir!("#{@storage_path}/#{study_dir}")
      end
    end)
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

  describe "create_result_file/1" do
    test "creates file at correct location", %{study: study, task: task, result: result} do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")
      :ok = File.mkdir("#{@storage_path}/#{study.id}/#{task.id}")

      :ok = Storage.create_result_file(result)

      assert File.exists?(
               "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}.#{@file_extension}"
             )
    end
  end

  describe "append_result_file/2" do
    test "appends data to created results file", %{
      study: study,
      task: task,
      result: result
    } do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")
      :ok = File.mkdir("#{@storage_path}/#{study.id}/#{task.id}")

      path =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}.#{@file_extension}"

      :ok = File.write(path, "")

      chunk1 = "chunk1data"
      chunk2 = "chunk2data"
      chunk3 = "chunk3data"

      :ok = Storage.append_result_file(result, chunk1)
      {:ok, ",chunk1data"} = File.read(path)

      :ok = Storage.append_result_file(result, chunk2)
      {:ok, ",chunk1data,chunk2data"} = File.read(path)

      :ok = Storage.append_result_file(result, chunk3)
      {:ok, ",chunk1data,chunk2data,chunk3data"} = File.read(path)
    end
  end

  describe "complete_file_storage/1" do
    test "gzips content and renames file with .gzip file extension", %{
      study: study,
      task: task,
      result: result
    } do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")
      :ok = File.mkdir("#{@storage_path}/#{study.id}/#{task.id}")

      path =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}.#{@file_extension}"

      unzipped_content = "A few chunks"
      :ok = File.write(path, unzipped_content)

      :ok = Storage.complete_file_storage(result)

      assert File.exists?(
               "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}.#{@completed_extension}"
             )

      refute File.exists?(
               "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}.#{@file_extension}"
             )

      {:ok, gzipped_content} =
        File.read(
          "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}.#{@completed_extension}"
        )

      result = :zlib.gunzip(gzipped_content)
      assert result == unzipped_content
    end
  end

  describe "get_completed_file_content/1" do
    test "returns content stored in a completed file", %{
      study: study,
      task: task,
      result: result
    } do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")
      :ok = File.mkdir("#{@storage_path}/#{study.id}/#{task.id}")

      path =
        "#{@storage_path}/#{study.id}/#{task.id}/#{result.unique_participant_id}.#{@completed_extension}"

      unzipped_content = "A few chunks"
      gzipped_content = :zlib.gzip(unzipped_content)
      :ok = File.write(path, gzipped_content)

      assert unzipped_content == Storage.get_completed_file_content(result)
    end
  end
end
