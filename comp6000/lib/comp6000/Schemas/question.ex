defmodule Comp6000.Schemas.Question do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Study, Result, Answer}

  schema "question" do
    belongs_to(:study, Study)
    has_many(:result, Result)
    has_one(:answer, Answer)
    field(:question_num, :integer)
    field(:question_content, :string)
    field(:optional_info, :string)

    timestamps()
  end
end
