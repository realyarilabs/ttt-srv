defmodule TttsrvWeb.Clients.Simulation do
  alias TttsrvWeb.Clients.GameClient
  @user_id_1 "user_1"
  @user_id_2 "user_2"

  # @client_config_1 [
  #   uri: "wss://ttt-srv.yarilabs.com/socket/websocket?user_id=#{@user_id_1}"
  # ]
  # @client_config_2 [
  #   uri: "wss://ttt-srv.yarilabs.com/socket/websocket?user_id=#{@user_id_2}"
  # ]

  @client_config_1 [uri: "ws://localhost:4000/socket/websocket?user_id=#{@user_id_1}"]
  @client_config_2 [uri: "ws://localhost:4000/socket/websocket?user_id=#{@user_id_2}"]

  def at_battle() do
    {:ok, pid_1} = GameClient.start_link(@client_config_1, PLAYER1)
    :timer.sleep(500)
    {:ok, pid_2} = GameClient.start_link(@client_config_2, PLAYER2)

    [pid_1, pid_2]
  end

  @doc """
  Expanding the Simulation for Broadcast Messages

  Objective:
  Test the broadcast message feature by simulating a scenario where one client
  sends a message, and both clients verify receiving this message.

  Steps to Add Broadcast Message Testing:
  * Update the GameClient Module:
  * Add a function to send a broadcast message.
  * Handle receiving broadcast messages in handle_message/4.

  Enhance the Simulation:
  * Simulate sending a broadcast message from one client.
  * Verify that both clients receive the message.
  """

  def simulate_battle do
    pids = at_battle()

    :timer.sleep(500)

    GameClient.move(PLAYER1, 0, 0)
    GameClient.move(PLAYER2, 1, 0)
    GameClient.move(PLAYER1, 0, 1)
    GameClient.move(PLAYER2, 1, 1)
    GameClient.move(PLAYER1, 0, 2)

    :timer.sleep(500)
    # kill the process
    pids |> Enum.each(fn pid -> Process.exit(pid, :kill) end)
  end
end
