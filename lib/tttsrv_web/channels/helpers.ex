defmodule TttsrvWeb.Helpers do
  def get_player(state, user_id) do
    cond do
      state.players["X"] == user_id -> {:ok, "X"}
      state.players["O"] == user_id -> {:ok, "O"}
      true -> {:error, :not_a_player}
    end
  end

  def get_opponent(state, user_id) do
    cond do
      state.players["X"] == user_id -> {:ok, state.players["O"]}
      state.players["O"] == user_id -> {:ok, state.players["X"]}
      true -> {:error, :not_a_player}
    end
  end

  defp get_player_by_symbol(symbol, state) do
    case symbol do
      "X" -> state.players["X"]
      "O" -> state.players["O"]
    end
  end

  def next_player(state) do
    cond do
      state.current_player == state.players["X"] -> %{state | current_player: state.players["O"]}
      state.current_player == state.players["O"] -> %{state | current_player: state.players["X"]}
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
        if Enum.at(board, x1) |> Enum.at(y1) != "" &&
             Enum.at(board, x1) |> Enum.at(y1) == Enum.at(board, x2) |> Enum.at(y2) &&
             Enum.at(board, x1) |> Enum.at(y1) == Enum.at(board, x3) |> Enum.at(y3) do
          Enum.at(board, x1) |> Enum.at(y1) |> get_player_by_symbol(state)
        end
      end)

    if winning_symbol do
      %{state | winner: winning_symbol, status: "game_over"}
    else
      if Enum.all?(board, fn row -> Enum.all?(row, fn cell -> cell != "" end) end) do
        %{state | winner: "draw", status: "game_over"}
      else
        state
      end
    end
  end
end
