defmodule TttsrvWeb.GameServer do
  alias TttsrvWeb.Helpers
  alias TttsrvWeb.Validate
  use GenServer

  def init(state), do: {:ok, state}

  def add_player(game_id, user_id, name \\ nil) do
    GenServer.call(via_tuple(game_id), {:add_player, user_id, name})
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

  def play_again(game_id) do
    GenServer.call(via_tuple(game_id), :play_again)
  end

  def handle_call({:add_player, user_id, name}, _from, state) do
    new_state = add_player_to_game(state, user_id, name)
    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:move, user_id, x, y}, _from, state) do
    case move_in_board(state, user_id, x, y) do
      {:ok, new_state, symbol} ->
        {:reply, {:ok, new_state, symbol}, new_state}

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

  def handle_call(:play_again, _from, state) do
    state = play_again_game_state(state)
    {:reply, {:ok, state}, state}
  end

  def initial_game_state(game_id) do
    %{
      player_1: nil,
      player_2: nil,
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

  def play_again_game_state(state) do
    %{
      state
      | board: [
          ["", "", ""],
          ["", "", ""],
          ["", "", ""]
        ],
        status: "started",
        current_player: [state.players["X"], state.players["O"]] |> Enum.random(),
        winner: nil
    }
  end

  def add_player_to_game(state, user_id, name \\ nil) do
    cond do
      state.players["X"] == nil ->
        new_state = %{state | players: Map.put(state.players, "X", user_id)}

        if name do
          %{new_state | player_1: name}
        else
          %{new_state | player_1: "Player 1"}
        end

      state.players["O"] == nil and state.players["X"] !== user_id ->
        new_state = %{
          state
          | players: Map.put(state.players, "O", user_id),
            current_player: [state.players["X"], user_id] |> Enum.random(),
            status: "started"
        }

        if name do
          %{new_state | player_2: name}
        else
          %{new_state | player_2: "Player 2"}
        end

      true ->
        state
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

      {:ok, updated_state, symbol}
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
