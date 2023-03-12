defmodule Extr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @telemetry_events [
    [:bandit, :request, :start],
    [:bandit, :request, :stop],
    [:bandit, :request, :exception],
    [:bandit, :websocket, :start],
    [:bandit, :websocket, :stop]
  ]

  @impl true
  def start(_type, _args) do
    :ok =
      :telemetry.attach_many(
        "extr-telemetry",
        @telemetry_events,
        &Extr.Telemetry.handle_event/4,
        nil
      )

    children = [
      Extr.Telemetry.Metrics,
      {Bandit, plug: Extr.Endpoint}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Extr.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
