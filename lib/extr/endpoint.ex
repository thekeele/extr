defmodule Extr.Endpoint do
  @moduledoc """
  Extr Endpoint

  Handles all incoming requests

  Only requests with the upgrade websocket header are accepted

  Once accepted the connection is upgraded and passed to the relay
  """
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "upgrade") do
      ["websocket"] ->
        upgrade_adapter(conn, :websocket, {Extr.Relay, [], []})

      _ ->
        resp(conn, 426, "websocket")
    end
  end
end
