defmodule Extr.Telemetry.Metrics do
  @moduledoc """
  Extr Telemetry Metrics Store

  This module receives telement events, measurements, and metadata

  Handles the spans emitted by Bandit related to request and websocket lifecycles

  https://hexdocs.pm/bandit/Bandit.Telemetry.html
  """
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info(
        {[:bandit, :request, :start] = event, _, %{span_id: span_id}},
        state
      ) do
    Logger.info(inspect(event))

    {:noreply, Map.put(state, span_id, %{})}
  end

  def handle_info(
        {[:bandit, :request, :stop] = event,
         %{
           time: time,
           duration: duration
         }, %{span_id: span_id}},
        state
      ) do
    Logger.info(inspect(event))

    metrics = %{
      request_start_time: time,
      request_duration: convert_time_unit(duration)
    }

    {:noreply, Map.put(state, span_id, metrics)}
  end

  def handle_info(
        {[:bandit, :request, :exception] = event,
         %{
           time: time
         }, %{span_id: span_id, kind: kind, exception: exception}},
        state
      ) do
    Logger.info(inspect(event))

    metrics =
      state
      |> Map.get(span_id, %{})
      |> Map.put(:exception_time, time)
      |> Map.put(:kind, kind)
      |> Map.put(:exception, exception)

    {:noreply, Map.put(state, span_id, metrics)}
  end

  def handle_info(
        {[:bandit, :websocket, :start] = event, _,
         %{origin_span_id: origin_span_id, span_id: span_id}},
        state
      ) do
    Logger.info(inspect(event))

    metrics =
      state
      |> Map.get(origin_span_id)
      |> Map.put(:origin_span_id, origin_span_id)

    state =
      state
      |> Map.put(span_id, metrics)
      |> Map.delete(origin_span_id)

    {:noreply, state}
  end

  def handle_info(
        {[:bandit, :websocket, :stop] = event,
         %{
           time: time,
           duration: duration
         }, %{span_id: span_id}},
        state
      ) do
    Logger.info(inspect(event))

    metrics =
      state
      |> Map.get(span_id)
      |> Map.put(:websocket_start_time, time)
      |> Map.put(:websocket_duration, convert_time_unit(duration))

    {:noreply, Map.put(state, span_id, metrics)}
  end

  defp convert_time_unit(native_time, to_unit \\ :millisecond) do
    System.convert_time_unit(native_time, :native, to_unit)
  end
end
