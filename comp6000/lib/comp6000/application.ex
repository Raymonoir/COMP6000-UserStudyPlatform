defmodule Comp6000.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Comp6000.Repo,
      # Start the Telemetry supervisor
      Comp6000Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Comp6000.PubSub},
      # Start the Endpoint (http/https)
      Comp6000Web.Endpoint
      # Start a worker by calling: Comp6000.Worker.start_link(arg)
      # {Comp6000.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Comp6000.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Comp6000Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
