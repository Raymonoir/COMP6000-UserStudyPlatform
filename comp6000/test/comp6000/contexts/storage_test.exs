defmodule Comp6000.Contexts.StorageTest do
  use Comp6000.DataCase, async: true
  alias Comp6000.Schemas.{Study, Task, Metrics}
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

    {:ok, metrics} =
      %Metrics{}
      |> Metrics.changeset(%{
        study_id: study.id,
        participant_uuid: "567f56d67s67as76d7s8"
      })
      |> Repo.insert()

    %{study: study, task: task, metrics: metrics}
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

  describe "create_participant_directory/1" do
    test "creates directory using a metrics", %{study: study, metrics: metrics} do
      :ok = File.mkdir("#{@storage_path}/#{study.id}")

      assert metrics = Storage.create_participant_directory(metrics)

      path = "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}"

      assert File.exists?(path)
    end
  end

  describe "create_participant_files/1" do
    test "creates files at correct location", %{study: study, metrics: metrics} do
      create_all_dirs(study, metrics)

      assert metrics == Storage.create_participant_files(metrics)

      assert File.exists?(
               "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@compile_filename}.#{@extension}"
             )

      assert File.exists?(
               "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@replay_filename}.#{@extension}"
             )

      assert File.read!(
               "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@replay_filename}.#{@extension}"
             ) == @file_start

      assert File.read!(
               "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@compile_filename}.#{@extension}"
             ) == @file_start
    end
  end

  describe "append_data/3" do
    test "appends data to replay_data file", %{
      study: study,
      metrics: metrics
    } do
      create_all_dirs(study, metrics)

      path =
        "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@replay_filename}.#{@extension}"

      :ok = File.write(path, @file_start)

      chunk1 = "chunk1data"
      chunk2 = "chunk2data"
      chunk3 = "chunk3data"

      :ok = Storage.append_data(metrics, chunk1, :replay)
      {:ok, "#{@file_start}chunk1data"} = File.read(path)

      :ok = Storage.append_data(metrics, chunk2, :replay)

      {:ok, "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data"} = File.read(path)

      :ok = Storage.append_data(metrics, chunk3, :replay)

      "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data#{@chunk_delimiter}chunk3data" =
        File.read!(path)
    end

    test "appends data to compile_data file", %{
      study: study,
      metrics: metrics
    } do
      create_all_dirs(study, metrics)

      path =
        "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@compile_filename}.#{@extension}"

      :ok = File.write(path, @file_start)

      chunk1 = "chunk1data"
      chunk2 = "chunk2data"
      chunk3 = "chunk3data"

      :ok = Storage.append_data(metrics, chunk1, :compile)
      {:ok, "#{@file_start}chunk1data"} = File.read(path)

      :ok = Storage.append_data(metrics, chunk2, :compile)

      {:ok, "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data"} = File.read(path)

      :ok = Storage.append_data(metrics, chunk3, :compile)

      "#{@file_start}chunk1data#{@chunk_delimiter}chunk2data#{@chunk_delimiter}chunk3data" =
        File.read!(path)
    end
  end

  describe "complete_data/2" do
    test "gzips content and renames replay_data file with .gzip file extension", %{
      study: study,
      metrics: metrics
    } do
      create_all_dirs(study, metrics)

      path_no_ext = "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@replay_filename}"

      unzipped_content = "#{@file_start}A few chunks"
      :ok = File.write("#{path_no_ext}.#{@extension}", unzipped_content)

      :ok = Storage.complete_data(metrics, :replay)

      assert File.exists?("#{path_no_ext}.#{@completed_extension}")

      refute File.exists?("#{path_no_ext}.#{@extension}")

      {:ok, gzipped_content} = File.read("#{path_no_ext}.#{@completed_extension}")

      content = :zlib.gunzip(gzipped_content)
      assert content == "#{unzipped_content}#{@file_end}"
    end

    test "gzips content and renames compile_data file with .gzip file extension", %{
      study: study,
      metrics: metrics
    } do
      create_all_dirs(study, metrics)

      path_no_ext =
        "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@compile_filename}"

      unzipped_content = "#{@file_start}A few chunks"
      :ok = File.write("#{path_no_ext}.#{@extension}", unzipped_content)

      :ok = Storage.complete_data(metrics, :compile)

      assert File.exists?("#{path_no_ext}.#{@completed_extension}")

      refute File.exists?("#{path_no_ext}.#{@extension}")

      {:ok, gzipped_content} = File.read("#{path_no_ext}.#{@completed_extension}")

      content = :zlib.gunzip(gzipped_content)
      assert content == "#{unzipped_content}#{@file_end}"
    end
  end

  describe "get_completed_data/2" do
    test "returns content stored in completed replay_data file", %{
      study: study,
      metrics: metrics
    } do
      create_all_dirs(study, metrics)

      path =
        "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@replay_filename}.#{@completed_extension}"

      unzipped_content = Jason.encode!(%{json: "data"})
      gzipped_content = :zlib.gzip(unzipped_content)
      :ok = File.write(path, gzipped_content)

      assert Jason.decode!(unzipped_content) == Storage.get_completed_data(metrics, :replay)
    end

    test "returns content stored in completed compile_data file", %{
      study: study,
      metrics: metrics
    } do
      create_all_dirs(study, metrics)

      path =
        "#{@storage_path}/#{study.id}/#{metrics.participant_uuid}/#{@compile_filename}.#{@completed_extension}"

      unzipped_content = Jason.encode!(%{json: "data"})
      gzipped_content = :zlib.gzip(unzipped_content)
      :ok = File.write(path, gzipped_content)

      assert Jason.decode!(unzipped_content) == Storage.get_completed_data(metrics, :compile)
    end
  end

  def create_all_dirs(study, metrics) do
    File.mkdir!("#{@storage_path}/#{study.id}")
    File.mkdir!("#{@storage_path}/#{study.id}/#{metrics.participant_uuid}")
  end
end
