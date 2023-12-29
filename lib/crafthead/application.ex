defmodule Crafthead.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Nebulex cache
      {Crafthead.Cache, []},
      # Start the Telemetry supervisor
      CraftheadWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Crafthead.PubSub},
      # Start the Endpoint (http/https)
      CraftheadWeb.Endpoint
      # Start a worker by calling: Crafthead.Worker.start_link(arg)
      # {Crafthead.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crafthead.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CraftheadWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
