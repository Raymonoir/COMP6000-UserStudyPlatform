defmodule Comp6000Web.Plugs.Session do
  import Plug.Conn

  '''
  With regards to the session and assigns within the conn:

  - The assigns map is used to pass data form one layer to other layers downstream
    but is cleared on every request so if you put something in there,
    it will be lost if a new request is made

  - The session is what persists through requests, that is why we first check if there
    is already a logged in user within the session, and if we find one we place it in the assigns
    which then means we can use this in downstream layers

  - In the UsersController (comp6000/lib/comp6000_web/controllers/users_controller.ex), which is downstream
    from this plug, we place the user's username in the session which will then be picked up by this plug
    in the next request.

  '''

  def init(opts), do: opts

  def call(conn, _opts) do
    username = get_session(conn, :username)

    user =
      case username do
        nil -> nil
        username -> Comp6000.Contexts.Users.get_user_by(username: username)
      end

    assign(conn, :current_user, user)
  end
end
