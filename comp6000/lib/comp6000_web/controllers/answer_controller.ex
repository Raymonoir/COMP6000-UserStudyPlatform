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
end
