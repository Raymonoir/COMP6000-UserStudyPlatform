defmodule Comp6000.Contexts.Results do
  alias Comp6000.Repo
  alias Comp6000.Schemas.Result

  def get_result_by(params) do
    Repo.get_by(Result, params)
  end

  def create_result(params \\ %{}) do
    %Result{}
    |> Result.changeset(params)
    |> Repo.insert()
  end

  def delete_result(%Result{} = result) do
    Repo.delete(result)
  end
end
