defmodule Comp6000.Schemas.Answer do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.Task

  schema "answer" do
    belongs_to(:task, Task)
    field(:content, :string)

    timestamps()
  end
end
