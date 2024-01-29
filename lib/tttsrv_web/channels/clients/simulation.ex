defmodule TttsrvWeb.Clients.Simulation do
  alias TttsrvWeb.Clients.BattleClient
  @user_id_1 "user_1"
  @user_id_2 "user_2"

  @client_confi_1 [uri: "ws://localhost:4000/socket/websocket?user_id=#{@user_id_1}"]
  @client_confi_2 [uri: "ws://localhost:4000/socket/websocket?user_id=#{@user_id_2}"]

  def at_battle() do
    {:ok, pid_1} = BattleClient.start_link(@client_confi_1, PLAYER1)
    :timer.sleep(500)
    {:ok, pid_2} = BattleClient.start_link(@client_confi_2, PLAYER2)

    [pid_1, pid_2]
  end

  def simulate_battle do
    pids = at_battle()

    :timer.sleep(500)

    BattleClient.move(PLAYER1, 0, 0)

    :timer.sleep(500)
    # kill the process
    pids |> Enum.each(fn pid -> Process.exit(pid, :kill) end)
  end
end
