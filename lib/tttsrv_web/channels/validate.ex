defmodule TttsrvWeb.Validate do
  def position(state, x, y) do
    if x >= 0 and x <= 2 and y >= 0 and y <= 2 and Enum.at(Enum.at(state.board, x), y) == "" do
      :ok
    else
      {:error, :invalid_position}
    end
  end

  def game_started(state) do
    if state.status == "started" do
      :ok
    else
      {:error, :game_not_started}
    end
  end

  def player_turn(state, user_id) do
    if state.current_player == user_id do
      :ok
    else
      {:error, :not_your_turn}
    end
  end
end
