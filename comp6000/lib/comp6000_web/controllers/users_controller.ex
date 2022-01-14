defmodule Comp6000Web.UsersController do
  use Comp6000Web, :controller
  import Plug.Conn

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
    |> configure_session(renew: true)
  end
end
