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

  def get(conn, %{"task_id" => task_id} = _params) do
    answer = Answers.get_answer_by(task_id: task_id)

    json(conn, %{answer: answer})
  end

  def edit(conn, %{"task_id" => task_id} = params) do
    answer = Answers.get_answer_by(task_id: task_id)

    case Answers.update_answer(answer, params) do
      {:ok, answer} ->
        json(conn, %{updated_answer: answer.id})

      {:error, changeset} ->
        json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def delete(conn, %{"task_id" => task_id} = params) do
    answer = Answers.get_answer_by(task_id: task_id)
    {:ok, answer} = Answers.delete_answer(answer)
    json(conn, %{deleted_answer: answer.id})
  end
end
