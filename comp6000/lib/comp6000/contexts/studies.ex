defmodule Comp6000.Contexts.Studies do
  alias Comp6000.Repo
  alias Comp6000.Schemas.Study

  def get_all_studies() do
    Repo.all(Study)
  end

  def get_study_by(params) do
    Repo.get_by(Study, params)
  end

  def create_study(params \\ %{}) do
    %Study{}
    |> Study.changeset(params)
    |> Repo.insert()
  end

  def update_study(%Study{} = study, params) do
    study
    |> Study.changeset(params)
    |> Repo.update()
  end

  def delete_study(%Study{} = study) do
    Repo.delete(study)
  end
end
