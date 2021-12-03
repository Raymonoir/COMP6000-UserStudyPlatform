defmodule Comp6000.Schemas.Result do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.Task

  schema "result" do
    belongs_to(:task, Task)
    field(:unique_user_id, :string)
    field(:content, :string)

    timestamps()
  end
end
