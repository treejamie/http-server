defmodule Server do
  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Starting server on http://127.0.0.1:4221")
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  def listen() do
    {:ok, socket} = :gen_tcp.listen(4221, [:binary, active: false, reuseaddr: true])
    loop(socket)
  end

  defp loop(socket) do
    # this is the boundary - naive assumption checks of a perfect world.
    with {:ok, client_socket} <- :gen_tcp.accept(socket),
         {:ok, request} = :gen_tcp.recv(client_socket, 0) do
      # logging - becasue reasons
      Logger.debug("#{inspect(request)}")

      # Construct, reduce, convert
      # construct
      request
      # reduce
      |> Server.Handler.handle()
      # convert
      |> to_string()
      # send it
      |> reply(client_socket)
    else
      {:error, error} -> Logger.error("loop error: #{inspect(error)}")
    end

    # and finally, tail recurse.
    loop(socket)
  end

  defp reply(response, client_socket) do
    # for now we blockand do one response at a time, return that response
    :gen_tcp.send(client_socket, response)
    :gen_tcp.close(client_socket)
  end

  def main(_args) do
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)
    Process.sleep(:infinity)
  end
end
