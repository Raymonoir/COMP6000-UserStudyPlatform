defmodule Comp6000.Schemas.Study do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{Question, User}

  @foreign_key_type :string
  schema "study" do
    belongs_to(:user, User, references: :username, foreign_key: :username)
    has_many(:question, Question)
    field(:title, :string)
    field(:question_count, :integer)

    timestamps()
  end
end
