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
  Challenge SEI 2:

  Expanding the Simulation for Broadcast Messages

  Objective:
  Test the broadcast message feature by simulating a scenario where one client
  sends a message, and both clients verify receiving this message.

  Before starting this Challenge Analyze the function simulate_battle/0
    in the Simulation module to get a better understanding of the simulation.

  Steps to Add Broadcast Message Testing:
  * Create a function simulate_chat/0 in the Simulation module.
  * Start by starting the pids of both clients.
  * Use GameClient Module that has the function broadcast_message/2 to send a message from one client.
  * Kill the process after a short delay (like we do in simulate_battle).
  * Handle receiving broadcast messages in handle_message/4.

  * Go to Challenge SEI 3 (game_client.ex) in the GameClient module to complete the handle_message/4 function.

  * Run "mix phx.server" in your console to start the server.
  * In another console, run "iex -S mix" and call TttsrvWeb.Clients.Simulation.simulate_chat/0 to test the broadcast message feature.
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
    pids |> Enum.each(fn pid -> Process.exit(pid, :normal) end)
  end
end
