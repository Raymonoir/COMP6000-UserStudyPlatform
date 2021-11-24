defmodule Comp6000Web.SessionPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    user =
      case user_id do
        nil -> nil
        user_id -> Comp6000.Contexts.Users.get_user_by(id: user_id)
      end

    assign(conn, :current_user, user)
  end
end
