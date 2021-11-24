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
    |> cast(params, [:username, :firstname, :lastname, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_changeset()
    |> set_password_hash()
  end

  def update_changeset(%User{} = user, params) do
    user
    |> cast(params, [:username, :firstname, :lastname, :email, :password])
    |> validate_changeset()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:username, min: 1, max: 100)
    |> unique_constraint(:username)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 10, max: 100)
  end

  defp set_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
        put_change(changeset, :password, nil)

      _else ->
        changeset
    end
  end
end
