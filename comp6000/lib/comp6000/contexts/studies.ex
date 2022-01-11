defmodule Comp6000.Contexts.Studies do
  import Ecto.Query
  alias Comp6000.Repo
  alias Comp6000.Schemas.{Study, User}

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

  def get_studies_for_user(%User{} = user) do
    query = from(s in Study, where: s.username == ^user.username)

    Repo.all(query)
  end
end
