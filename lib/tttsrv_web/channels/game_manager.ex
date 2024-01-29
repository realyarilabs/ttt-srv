defmodule TttsrvWeb.GameManager do
  use GenServer
  alias TttsrvWeb.GameServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def start_game(game_id) do
    GenServer.call(__MODULE__, {:start_game, game_id})
  end

  def init(_), do: {:ok, %{}}

  def handle_call({:start_game, game_id}, _from, state) do
    case Registry.lookup(Tttsrv.GameRegistry, game_id) do
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

  # Aux functions
  defp via_tuple(game_id) do
    {:via, Registry, {GameRegistry, game_id}}
  end
end
