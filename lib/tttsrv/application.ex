defmodule Tttsrv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TttsrvWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:tttsrv, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tttsrv.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Tttsrv.Finch},
      # Start a worker by calling: Tttsrv.Worker.start_link(arg)
      # {Tttsrv.Worker, arg},

      # Starts the Registry to register the game servers for the TicTacToe game

      {Registry, keys: :unique, name: TttsrvWeb.GameRegistry},

      # starts the game manager that orchestrates the gameservers

      TttsrvWeb.GameManager,
      # Start to serve requests, typically the last entry
      TttsrvWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tttsrv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TttsrvWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
