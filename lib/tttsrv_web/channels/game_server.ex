defmodule TttsrvWeb.GameServer do
  alias TttsrvWeb.Helpers
  alias TttsrvWeb.Validate
  use GenServer

  def init(state), do: {:ok, state}

  def add_player(game_id, player) do
    GenServer.call(via_tuple(game_id), {:add_player, player})
  end

  def move(game_id, player, x, y) do
    GenServer.call(via_tuple(game_id), {:move, player, x, y})
  end

  def get_state(game_id) do
    GenServer.call(via_tuple(game_id), :get_state)
  end

  def surrender(game_id, user_id) do
    GenServer.call(via_tuple(game_id), {:surrender, user_id})
  end

  def handle_call({:add_player, user_id}, _from, state) do
    case add_player_to_game(state, user_id) do
      {:ok, new_state} ->
        {:reply, {:ok, new_state}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:move, user_id, x, y}, _from, state) do
    case move_in_board(state, user_id, x, y) do
      {:ok, new_state} ->
        {:reply, {:ok, new_state}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call({:surrender, user_id}, _from, state) do
    case Helpers.get_opponent(state, user_id) do
      {:ok, symbol} ->
        new_state = %{state | winner: symbol, status: "game_over"}
        {:reply, {:ok, new_state}, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def initial_game_state(game_id) do
    %{
      game_id: game_id,
      board: [
        ["", "", ""],
        ["", "", ""],
        ["", "", ""]
      ],
      status: "waiting",
      players: %{
        "X" => nil,
        "O" => nil
      },
      current_player: nil,
      winner: nil
    }
  end

  def add_player_to_game(state, user_id) do
    cond do
      state.players["X"] == nil ->
        new_state = %{state | players: Map.put(state.players, "X", user_id)}
        {:ok, new_state}

      state.players["O"] == nil ->
        new_state = %{state | players: Map.put(state.players, "O", user_id)}

        {:ok,
         %{
           new_state
           | current_player: state.players["X"],
             status: "started"
         }}

      state.players["X"] == user_id or state.players["O"] == user_id ->
        {:ok, state}

      true ->
        {:error, :game_full}
    end
  end

  def move_in_board(state, user_id, x, y) do
    with :ok <-
           Validate.game_started(state),
         :ok <- Validate.position(state, x, y),
         :ok <- Validate.player_turn(state, user_id),
         {:ok, symbol} <- Helpers.get_player(state, user_id) do
      updated_row = List.replace_at(Enum.at(state.board, x), y, symbol)
      updated_board = List.replace_at(state.board, x, updated_row)

      updated_state =
        %{state | board: updated_board}
        |> Helpers.next_player()
        |> Helpers.check_end_game()

      {:ok, updated_state}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  # Aux functions

  defp via_tuple(game_id) do
    {:via, Registry, {TttsrvWeb.GameRegistry, game_id}}
  end
end
