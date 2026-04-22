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
    with {:ok, client} <- :gen_tcp.accept(socket),
         {:ok, request} = :gen_tcp.recv(client, 0) do
      Logger.debug("#{inspect(request)}")
      response = response(request)

      :gen_tcp.send(client, response)
      :gen_tcp.close(client)
    else
      {:error, error} -> Logger.error("loop error: #{inspect(error)}")
    end

    loop(socket)
  end

  defp response(request) do
    # Split into lines first
    [request_line | _header_lines] = String.split(request, "\r\n", trim: true)

    # Then split the request line on spaces
    [_method, path, _version] = String.split(request_line, " ")

    case path do
      "/" -> "HTTP/1.1 200 OK\r\n\r\n"
      _ -> "HTTP/1.1 404 Not Found\r\n\r\n"
    end
  end

  def main(_args) do
    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)
    Process.sleep(:infinity)
  end
end
