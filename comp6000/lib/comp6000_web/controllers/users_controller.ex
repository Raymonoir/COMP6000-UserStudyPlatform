defmodule Comp6000Web.UsersController do
  use Comp6000Web, :controller

  def login(conn, %{"password" => password, "username" => username} = _params) do
    json(conn, %{login: Comp6000Web.Authentication.login(username, password)})
  end

  def login(conn, _params) do
    json(conn, %{login: nil})
  end
end
