defmodule Comp6000Web.Study.StudyController do
  use Comp6000Web, :controller
  import Plug.Conn
  alias Comp6000.Contexts.{Storage, Studies, Tasks, Results}

  def create(conn, params) do
    case Studies.create_study(params) do
      {:ok, study} ->
        Storage.create_study_directory(study)
        json(conn, %{created_study: study.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end
end
