defmodule Comp6000Web.User.UserController do
  use Comp6000Web, :controller
  import Plug.Conn
  alias Comp6000.Contexts.Users

  def login(conn, %{"username" => username, "password" => password} = _params) do
    case Comp6000Web.Authentication.login(username, password) do
      {true, user} ->
        json(log_in_user(conn, user), %{login: true})

      {false, _user} ->
        json(conn, %{login: false})
    end
  end

  def login(conn, _params) do
    json(conn, %{login: false})
  end

  def create(conn, params) do
    case Comp6000.Contexts.Users.create_user(params) do
      {:ok, user} -> json(conn, %{created: user.username})
      {:error, changeset} -> json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def logged_in(conn, _params) do
    logged_in = if conn.assigns[:current_user] != nil, do: true, else: false
    json(conn, %{loggedIn: logged_in})
  end

  def logout(conn, _params) do
    json(configure_session(conn, drop: true), %{login: false})
  end

  defp log_in_user(conn, user) do
    conn
    |> put_session(:username, user.username)
    |> put_session(:current_participant, nil)
    |> configure_session(renew: true)
  end

  def get_studies(conn, _params) do
    current_user = get_session(conn, :current_user)

    if current_user == nil do
      json(conn, %{user: "not logged in"})
    else
      json(conn, user_studies: Comp6000.Contexts.Studies.get_studies_for_user(current_user))
    end
  end

  def edit(conn, %{"username" => username} = params) do
    user = Users.get_user_by(username: username)

    case Users.update_user(user, params) do
      {:ok, user} -> json(conn, %{updated_user: user.username})
      {:error, changeset} -> json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end

  def delete(conn, %{"username" => username} = _params) do
    user = Users.get_user_by(username: username)

    case Users.delete_user(user) do
      {:ok, user} -> json(conn, %{deleted_user: user.username})
      {:error, changeset} -> json(conn, %{error: Helpers.get_changeset_errors(changeset)})
    end
  end
end
