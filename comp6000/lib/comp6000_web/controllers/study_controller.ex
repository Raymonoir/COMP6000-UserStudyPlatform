defmodule Comp6000Web.Study.StudyController do
  use Comp6000Web, :controller
  import Plug.Conn
  alias Comp6000.Contexts.{Storage, Studies, Tasks, Users}

  def create(conn, params) do
    case Studies.create_study(params) do
      {:ok, study} ->
        json(conn, %{created_study: study.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def edit(conn, %{"study_id" => study_id} = params) do
    study = Studies.get_study_by(id: study_id)

    case Studies.update_study(study, params) do
      {:ok, study} ->
        json(conn, %{updated_study: study.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def delete(conn, %{"study_id" => study_id} = _params) do
    study = Studies.get_study_by(id: study_id)
    {:ok, study} = Studies.delete_study(study)
    json(conn, %{deleted_study: study.id})
  end

  def get(conn, %{"participant_code" => participant_code} = _params) do
    study = Studies.get_study_by(participant_code: participant_code)
    return_study(conn, study)
  end

  def get(conn, %{"study_id" => study_id} = _params) do
    study = Studies.get_study_by(id: study_id)
    return_study(conn, study)
  end

  def get(conn, %{"username" => username} = _params) do
    studies = Studies.get_studies_for_user(Users.get_user_by(username: username))

    if studies != nil do
      studies = Enum.map(studies, fn study -> Studies.get_all_for_study(study) end)
      json(conn, %{study: studies})
    else
      json(conn, %{study: nil})
    end
  end

  defp return_study(conn, study) do
    if study != nil do
      study = Studies.get_all_for_study(study)
      json(conn, %{study: study})
    else
      json(conn, %{study: nil})
    end
  end
end
