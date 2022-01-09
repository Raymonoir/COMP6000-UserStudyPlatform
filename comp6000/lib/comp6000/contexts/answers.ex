defmodule Comp6000.Contexts.Answers do
  alias Comp6000.Repo
  alias Comp6000.Schemas.Answer

  def get_answer_by(params) do
    Repo.get_by(Answer, params)
  end

  def create_answer(params \\ %{}) do
    %Answer{}
    |> Answer.changeset(params)
    |> Repo.insert()
  end

  def update_answer(%Answer{} = answer, params) do
    Answer.changeset(answer, params)
    |> Repo.update()
  end

  def delete_answer(%Answer{} = answer) do
    Repo.delete(answer)
  end
end
