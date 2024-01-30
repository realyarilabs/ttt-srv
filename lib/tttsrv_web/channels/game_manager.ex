defmodule TttsrvWeb.GameManager do
  use GenServer
  require Logger
  alias TttsrvWeb.{GameServer, GameRegistry}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def start_game(game_id) do
    GenServer.call(__MODULE__, {:start_game, game_id})
  end

  def init(_), do: {:ok, %{}}

  def handle_call({:start_game, game_id}, _from, state) do
    Logger.info("Starting game #{game_id}")

    case Registry.lookup(GameRegistry, game_id) do
      [{_, _pid}] ->
        {:reply, {:error, :game_already_started}, state}

      [] ->
        {:ok, pid} =
          GenServer.start_link(GameServer, GameServer.initial_game_state(game_id),
            name: via_tuple(game_id)
          )

        {:reply, {:ok, pid}, state}
    end
  end

  def handle_cast({:game_over, game_id}, state) do
    Process.send_after(self(), {:terminate_game, game_id}, 60_000)
    {:noreply, state}
  end

  def handle_info({:terminate_game, game_id}, state) do
    GenServer.stop(via_tuple(game_id))
    {:noreply, state}
  end

  # Aux functions
  defp via_tuple(game_id) do
    {:via, Registry, {GameRegistry, game_id}}
  end
end
