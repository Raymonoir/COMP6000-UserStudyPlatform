defmodule Comp6000Web.TaskController do
  use Comp6000Web, :controller

  def create(conn, params) do
    json(conn, %{not: "finished"})
  end

  def get_tasks(conn, %{"study_id" => study_id} = _params) do
    study = Studies.get_study_by(id: study_id)
    all_studies = Tasks.get_all_tasks_for_study(study)
    json(conn, %{tasks_for_study: all_studies})
  end
end
