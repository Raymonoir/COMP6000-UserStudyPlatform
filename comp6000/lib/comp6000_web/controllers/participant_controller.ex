defmodule Comp6000Web.Participant.ParticipantController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Tasks, Storage}

  def get_participant_uuid(conn, _params) do
    uuid = get_session(conn, :current_participant)
    json(conn, %{current_participant: uuid})
  end
end
