defmodule Comp6000Web.Participant.ParticipantController do
  use Comp6000Web, :controller
  alias Comp6000.Contexts.{Tasks, Results, Storage}

  def get_participant_uuid(conn, _params) do
    uuid = get_session(conn, :current_participant)
    json(conn, %{current_participant: uuid})
  end

  def get_participant_results(conn, %{"participant_uuid" => uuid} = _params) do
    results = Results.get_all_results_for_uuid(uuid)
    json(conn, %{results: results})
  end
end
