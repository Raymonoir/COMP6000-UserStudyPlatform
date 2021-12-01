defmodule Comp6000.Schemas.Answer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.Question

  schema "answer" do
    belongs_to(:question, Question)
    field(:content, :string)

    timestamps()
  end
end
