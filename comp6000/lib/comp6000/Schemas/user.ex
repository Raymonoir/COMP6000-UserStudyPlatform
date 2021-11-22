defmodule Comp6000.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.User

  schema "user" do
    field(:username, :string)
    field(:firstname, :string)
    field(:lastname, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)

    timestamps()
  end

  def changeset(%User{} = user, params) do
    user
    |> cast(params, [:username, :firstname, :lastname, :email, :password_hash])
    |> validate_required([:username, :email])
    |> unique_constraint(:username)
  end
end
