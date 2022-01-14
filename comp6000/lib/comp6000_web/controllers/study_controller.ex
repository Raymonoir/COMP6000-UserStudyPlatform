defmodule Comp6000Web.StudyController do
  use Comp6000Web, :controller
  import Plug.Conn

  def create(conn, params) do
    case Comp6000.Contexts.Studies.create_study(params) do
      {:ok, study} ->
        json(conn, %{created_study: study.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end
end
