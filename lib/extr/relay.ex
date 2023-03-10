defmodule Extr.Relay do
  @moduledoc """
  Extr Relay
  """

  def init(_) do
    {:ok, []}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def handle_in({message, [opcode: :text]}, state) do
    {:push, {:text, message}, state}
  end
end
