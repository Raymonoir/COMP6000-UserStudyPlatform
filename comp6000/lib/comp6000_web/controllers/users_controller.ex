defmodule Comp6000Web.UsersController do
  use Comp6000Web, :controller
  import Ecto.Changeset

  def login(conn, %{"username" => username, "password" => password} = _params) do
    json(conn, %{login: Comp6000Web.Authentication.login(username, password)})
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
