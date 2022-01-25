defmodule Comp6000Web.Study.AnswerController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.Answers

  def create(conn, params) do
    case Answers.create_answer(params) do
      {:ok, answer} ->
        json(conn, %{created_answer: answer.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def edit(conn, %{"answer_id" => answer_id} = params) do
    answer = Answers.get_answer_by(id: answer_id)

    case Answers.update_answer(answer, params) do
      {:ok, answer} ->
        json(conn, %{updated_answer: answer.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def delete(conn, %{"answer_id" => answer_id}) do
    answer = Answers.get_by(id: answer_id)
    {:ok, answer} = Answers.delete_answer(answer)
    json(conn, %{deleted_answer: answer.id})
  end
end
