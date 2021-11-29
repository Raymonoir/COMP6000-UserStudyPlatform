defmodule Comp6000.Contexts.Users do
  alias Comp6000.Repo
  alias Comp6000.Schemas.User

  def get_all_users() do
    Repo.all(User)
  end

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def create_user(params \\ %{}) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def update_user(%User{} = user, params) do
    User.update_changeset(user, params)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
