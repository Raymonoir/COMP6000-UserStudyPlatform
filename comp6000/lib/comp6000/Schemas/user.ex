defmodule Comp6000.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comp6000.Schemas.{User, Study}

  schema "user" do
    field(:username, :string, primary_key: true)
    field(:firstname, :string)
    field(:lastname, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    has_many(:studies, Study, references: :username, foreign_key: :username)

    timestamps()
  end

  def changeset(%User{} = user, params) do
    user
    |> cast(params, [:username, :firstname, :lastname, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_changeset()
    |> set_password_hash()
  end

  # Different changeset for updating because we do not *require* anything to be changed
  def update_changeset(%User{} = user, params) do
    user
    |> cast(params, [:username, :firstname, :lastname, :email, :password])
    |> validate_changeset()
    |> set_password_hash()
  end

  defp validate_changeset(changeset) do
    changeset
    |> validate_length(:username, min: 4, max: 100)
    |> unique_constraint(:username)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 10, max: 100)
  end

  defp set_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        changeset
        |> put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
        |> put_change(:password, nil)

      _else ->
        changeset
    end
  end
end
