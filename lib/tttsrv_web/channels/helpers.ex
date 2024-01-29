defmodule TttsrvWeb.Helpers do
  def get_player(state, user_id) do
    cond do
      state.players["X"] == user_id -> {:ok, "X"}
      state.players["O"] == user_id -> {:ok, "O"}
      true -> {:error, :not_a_player}
    end
  end

  def next_player(state) do
    cond do
      state.current_player == state.players["X"] -> state.players["O"]
      state.current_player == state.players["O"] -> state.players["X"]
    end
  end

  def check_end_game(state) do
    board = state.board

    winning_combinations = [
      [[0, 0], [0, 1], [0, 2]],
      [[1, 0], [1, 1], [1, 2]],
      [[2, 0], [2, 1], [2, 2]],
      [[0, 0], [1, 0], [2, 0]],
      [[0, 1], [1, 1], [2, 1]],
      [[0, 2], [1, 2], [2, 2]],
      [[0, 0], [1, 1], [2, 2]],
      [[0, 2], [1, 1], [2, 0]]
    ]

    winning_symbol =
      Enum.find_value(winning_combinations, fn [[x1, y1], [x2, y2], [x3, y3]] ->
        if board[x1][y1] != "" && board[x1][y1] == board[x2][y2] &&
             board[x1][y1] == board[x3][y3] do
          board[x1][y1]
        end
      end)

    if winning_symbol do
      {:ok, %{state | winner: winning_symbol, status: "game_over"}}
    else
      {:ok, state}
    end
  end
end
