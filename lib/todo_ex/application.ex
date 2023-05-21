defmodule TodoEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TodoExWeb.Telemetry,
      # Start the Ecto repository
      TodoEx.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: TodoEx.PubSub},
      # Start Finch
      {Finch, name: TodoEx.Finch},
      # Start the Endpoint (http/https)
      TodoExWeb.Endpoint
      # Start a worker by calling: TodoEx.Worker.start_link(arg)
      # {TodoEx.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TodoEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TodoExWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
