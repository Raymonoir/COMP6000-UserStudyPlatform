defmodule Comp6000Web.StudyControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Studies, Users}
  alias Comp6000.TestHelpers

  @storage_path Application.get_env(:comp6000, :storage_directory_path)

  setup do
    Users.create_user(%{
      username: "Ray123",
      email: "Ray123@email.com",
      password: "RaysPassword",
      firstname: "Raymond",
      lastname: "Ward"
    })

    on_exit(&TestHelpers.clear_local_storage/0)

    :ok
  end

  @valid_study %{
    title: "My Study",
    username: "Ray123",
    task_count: 0
  }

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
