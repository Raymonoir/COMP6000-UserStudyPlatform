defmodule Comp6000Web.PageController do
  use Comp6000Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
