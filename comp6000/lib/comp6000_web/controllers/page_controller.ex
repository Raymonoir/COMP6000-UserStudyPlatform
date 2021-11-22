defmodule Comp6000Web.PageController do
  use Comp6000Web, :controller

  def error(conn, _params) do
    json(conn, %{error: "404"})
  end
end
