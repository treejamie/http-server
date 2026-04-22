defmodule Server do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Starting server on http://127.0.0.1:4221")
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  def listen() do
    {:ok, socket} = :gen_tcp.listen(4221, [:binary, active: false, reuseaddr: true])

    with {:ok, client} <- :gen_tcp.accept(socket) do
      :gen_tcp.send(client, "HTTP/1.1 200 OK\r\n\r\n")
    else
      err -> err
    end
  end

  def main(_args) do
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)
    Process.sleep(:infinity)
  end
end
