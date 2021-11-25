defmodule Comp6000Web.Authentication do
  alias Comp6000.Contexts.Users

  def login(username, password) do
    user = Users.get_user_by(username: username)

    if user != nil do
      check_pass(user, password)
    else
      {false, nil}
    end
  end

  defp check_pass(user, password) do
    case Bcrypt.check_pass(user, password) do
      {:ok, _user} ->
        {true, user}

      _ ->
        {false, user}
    end
  end
end
