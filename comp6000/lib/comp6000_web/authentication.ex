defmodule Comp6000Web.Authentication do
  alias Comp6000.Contexts.Users

  def login(username, password) do
    user = Users.get_user_by(username: username)

    case Bcrypt.check_pass(user, password) do
      {:ok, _user} ->
        true

      _ ->
        false
    end
  end
end
