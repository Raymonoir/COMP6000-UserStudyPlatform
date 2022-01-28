defmodule Comp6000Web.Study.StudyController do
  use Comp6000Web, :controller
  import Plug.Conn
  alias Comp6000.Contexts.{Storage, Studies, Tasks, Results}

  def create(conn, params) do
    case Studies.create_study(params) do
      {:ok, study} ->
        json(conn, %{created_study: study.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def get_study_by_code(conn, %{"participant_code" => participant_code} = _params) do
    study = Studies.get_study_by(participant_code: participant_code)

    if study != nil do
      study = Studies.get_all_for_study(study)
      json(conn, %{study: study})
    else
      json(conn, %{study: nil})
    end
  end

  def get_study_by_id(conn, %{"id" => id} = _params) do
    study = Studies.get_study_by(id: id)

    if study != nil do
      study = Studies.get_all_for_study(study)
      json(conn, %{study: study})
    else
      json(conn, %{study: nil})
    end
  end
end
