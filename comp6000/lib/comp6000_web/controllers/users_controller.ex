defmodule Comp6000Web.UsersController do
  use Comp6000Web, :controller

  def login(conn, %{"password" => password, "username" => username}) do
    res = Comp6000Web.Authentication.login(username, password)
    json(conn, %{login: res})
  end

  def login(conn, params) do
    json(conn, %{login: nil})
  end
end
