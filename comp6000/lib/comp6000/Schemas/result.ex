defmodule Comp6000.Schemas.Result do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.Question

  schema "result" do
    belongs_to(:question, Question)
    field(:unique_user_id, :string)
    field(:content, :string)

    timestamps()
  end
end
