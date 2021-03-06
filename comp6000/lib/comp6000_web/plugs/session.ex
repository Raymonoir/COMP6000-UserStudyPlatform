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

    if username == nil do
      participant = get_session(conn, :current_participant)

      participant = if participant, do: participant, else: generate_unique_id()

      conn
      |> assign(:current_participant, participant)
      |> put_session(:current_participant, participant)
      |> configure_session(renew: true)
    else
      assign(conn, :current_user, Comp6000.Contexts.Users.get_user_by(username: username))
    end
  end

  def generate_unique_id() do
    UUID.uuid4()
  end
end
