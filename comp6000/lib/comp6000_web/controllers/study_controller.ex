defmodule Comp6000Web.StudyController do
  use Comp6000Web, :controller
  import Plug.Conn
  alias Comp6000.Contexts.Storage

  def create(conn, params) do
    case Comp6000.Contexts.Studies.create_study(params) do
      {:ok, study} ->
        Storage.create_study_directory(study)
        json(conn, %{created_study: study.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def background_submit(conn, %{"id" => id, "uuid" => uuid, "body" => body} = _params) do
    # Create and save answers related to tasks that will be the background check answers
  end

  def get_tasks(conn, %{"study_id" => study_id} = _params) do
  end
end
