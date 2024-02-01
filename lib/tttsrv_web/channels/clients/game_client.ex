defmodule TttsrvWeb.Clients.GameClient do
  @moduledoc """
  A simple Client connecting to the Lobby

  """

  use Slipstream
  require Logger

  @topic "games:match:1"

  def start_link(config, name \\ nil) do
    Slipstream.start_link(__MODULE__, config, name: name)
  end

  @impl Slipstream
  def init(config), do: {:ok, connect!(config)}

  @impl Slipstream
  def handle_connect(socket), do: {:ok, join(socket, @topic)}

  def move(pid, x, y) do
    socket = GenServer.call(pid, :get_socket)

    {:ok, _ref} = Slipstream.push(socket, @topic, "move", %{"x" => x, "y" => y})
    socket
  end

  def get_state(pid) do
    socket = GenServer.call(pid, :get_socket)

    {:ok, _ref} = Slipstream.push(socket, @topic, "request_game_state", %{})
  end

  @impl Slipstream
  def handle_message(@topic, event, payload, socket) do
    Logger.info("Event: #{inspect(event)} Payload: #{inspect(payload, pretty: true)}")

    {:ok, socket}
  end

  @impl Slipstream
  def handle_call(:get_socket, _from, socket), do: {:reply, socket, socket}
end
