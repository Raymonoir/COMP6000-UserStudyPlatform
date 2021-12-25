defmodule Comp6000.Contexts.StorageTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Contexts.{Storage, Studies, Users, Tasks}

  @storage_path Application.get_env(:comp6000, :storage_directory_path)
  setup do
    {:ok, user} =
      Users.create_user(%{username: "Ray123", email: "Ray@email.com", password: "password12345"})

    {:ok, study} =
      Studies.create_study(%{username: user.username, title: "A Study Title", task_count: 0})

    {:ok, task} =
      Tasks.create_task(%{content: "What is 2*2?", task_number: 1, study_id: study.id})

    on_exit(&clear_local_storage/0)

    %{study: study, task: task}
  end

  # An exceedingly nasty function to delete all files and directories within local-storage once tests are complete
  defp clear_local_storage() do
    Enum.map(File.ls!("#{@storage_path}"), fn study_dir ->
      Enum.map(File.ls!("#{@storage_path}/#{study_dir}"), fn task_dir ->
        Enum.map(File.ls!("#{@storage_path}/#{study_dir}/#{task_dir}"), fn file ->
          File.rm("#{@storage_path}/#{study_dir}/#{task_dir}/#{file}")
        end)

        File.rmdir!("#{@storage_path}/#{study_dir}/#{task_dir}")
      end)

      File.rmdir!("#{@storage_path}/#{study_dir}")
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
end
