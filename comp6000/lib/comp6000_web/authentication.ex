defmodule Comp6000Web.Authentication do
  alias Comp6000.Contexts.Users

  def login(username, password) do
    # Get user password from database
    user = Users.get_user_by(username: username)

    case Bcrypt.check_pass(user, password) do
      {:error, _reason} -> false
      _ -> true
    end
  end
end
