defmodule Comp6000Web.Participant.ParticipantControllerTest do
  use Comp6000Web.ConnCase, async: true
  alias Comp6000.Contexts.{Users, Studies, Tasks, Results}

  describe "GET /api/participant/get-uuid" do
    test "returns uuid of current participant", %{conn: conn} do
      conn = get(conn, "/api/participant/get-uuid")

      result = json_response(conn, 200)

      assert %{"current_participant" => uuid} = result

      conn = get(conn, "/api/participant/get-uuid")

      result = json_response(conn, 200)

      assert %{"current_participant" => ^uuid} = result
    end

    test "if researcher is logged in, current participant is nil", %{conn: conn} do
      Users.create_user(%{
        username: "Ray123",
        email: "Ray123@email.com",
        password: "RaysPassword",
        firstname: "Raymond",
        lastname: "Ward"
      })

      conn = post(conn, "/api/users/login", %{username: "Ray123", password: "RaysPassword"})
      conn = get(conn, "/api/participant/get-uuid")
      result = json_response(conn, 200)
      assert %{"current_participant" => nil} == result
    end
  end

  describe "GET /api/participant/:participant_uuid/list-results" do
    test "valid parameters returns list of results", %{conn: conn} do
      # Call random route to get uuid
      conn = get(conn, "/api/users/loggedin")
      uuid = get_session(conn, :current_participant)
      conn = get(conn, "/api/participant/#{uuid}/list-results")
      assert json_response(conn, 200) == %{"results" => []}
    end
  end
end
