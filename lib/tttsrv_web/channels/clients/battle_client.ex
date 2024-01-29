defmodule TttsrvWeb.Clients.BattleClient do
  @moduledoc """
  A simple Client connecting to the Lobby

  """

  @topic "games:battles:1"

  use Slipstream

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

  @impl Slipstream
  def handle_call(:get_socket, _from, socket), do: {:reply, socket, socket}
end
