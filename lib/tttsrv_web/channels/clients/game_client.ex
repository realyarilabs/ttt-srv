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

  def broadcast_message(pid, message) do
    socket = GenServer.call(pid, :get_socket)
    {:ok, _ref} = Slipstream.push(socket, @topic, "broadcast_message", %{"message" => message})
  end

  @doc """
  Challenge SEI 3:

  Objective:
  Create a handle for the message received from the event "game_message" in the GameClient module.

  Steps:
  * Create a handle_message/4 function in the GameClient module using pattern matching to handle the event "game_message".
  * Log the message received from the payload like "Game Message Received: message from sender_id".
  * Return {:ok, socket} at the end of the function.
  * Go back to challenge SEI 2 (simulation.ex) and see the magic happen.
  """

  @impl Slipstream
  def handle_message(@topic, event, payload, socket) do
    Logger.info("Event: #{inspect(event)} Payload: #{inspect(payload, pretty: true)}")

    {:ok, socket}
  end

  @impl Slipstream
  def handle_call(:get_socket, _from, socket), do: {:reply, socket, socket}
end
