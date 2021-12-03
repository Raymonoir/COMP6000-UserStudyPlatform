defmodule Comp6000.Schemas.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Study, Result, Answer}

  schema "question" do
    belongs_to(:study, Study)
    has_many(:result, Result)
    has_one(:answer, Answer)
    field(:task_number, :integer)
    field(:content, :string)
    field(:optional_info, :string)

    timestamps()
  end
end
