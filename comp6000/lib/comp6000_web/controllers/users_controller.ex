defmodule Comp6000Web.UsersController do
  use Comp6000Web, :controller
  import Ecto.Changeset
  import Plug.Conn

  def login(conn, %{"username" => username, "password" => password} = _params) do
    case Comp6000Web.Authentication.login(username, password) do
      {true, user} ->
        IO.inspect(conn)

        conn =
          conn
          |> put_session(:user_id, user.id)
          |> configure_session(renew: true)

        json(conn, %{login: true})

      {false, _user} ->
        json(conn, %{login: false})
    end
  end

  def login(conn, _params) do
    json(conn, %{login: nil})
  end

  def create(conn, params) do
    case Comp6000.Contexts.Users.create_user(params) do
      {:ok, user} -> json(conn, %{created: user.username})
      {:error, changeset} -> json(conn, %{error: get_changeset_errors(changeset)})
    end
  end

  def logged_in(conn, _params) do
    logged_in = if conn.assigns[:current_user] != nil, do: true, else: false
    json(conn, %{loggedIn: logged_in})
  end

  def logout(conn, _params) do
    json(configure_session(conn, drop: true), %{login: false})
  end

  defp get_changeset_errors(changeset) do
    errors_map =
      traverse_errors(changeset, fn {msg, opts} ->
        Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
          opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
        end)
      end)

    errors_map
    |> Map.keys()
    |> Enum.map(fn key -> "#{key} #{errors_map[key]}" end)
    |> Enum.join(",")
  end
end
