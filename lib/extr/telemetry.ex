defmodule Extr.Telemetry do
  @moduledoc """
  Extr Telemetry Handler

  This module handles all telemetry events attached during application start up

  Event handling is synchronous so events and its data are sent to a Metrics store for aggregation
  """
  alias __MODULE__.Metrics

  def handle_event(event, measurements, metadata, _config) do
    send(Metrics, {event, measurements, metadata})
  end
end
