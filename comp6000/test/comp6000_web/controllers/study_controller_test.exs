defmodule Comp6000Web.StudyControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Studies, Users}

  @storage_path Application.get_env(:comp6000, :storage_directory_path)

  setup do
    Users.create_user(%{
      username: "Ray123",
      email: "Ray123@email.com",
      password: "RaysPassword",
      firstname: "Raymond",
      lastname: "Ward"
    })

    on_exit(&clear_local_storage/0)

    :ok
  end

  @valid_study %{
    title: "My Study",
    username: "Ray123",
    task_count: 0
  }

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

  describe "POST /study/create" do
    test "create route with valid parameters creates study, and directory", %{conn: conn} do
      conn = post(conn, "/api/study/create", @valid_study)

      result = json_response(conn, 200)

      assert %{"created_study" => id} = result

      study = Studies.get_study_by(id: id)

      assert study != nil
      assert study.title == "My Study"

      assert File.exists?("#{@storage_path}/#{id}")
    end
  end
end
