defmodule Server do
  @moduledoc """
  The entrypoint for the main server loop.
  """
  use Application
  require Logger

  @spec start(Application.start_type(), map()) :: {:error, term()} | {:ok, pid()}
  def start(_type, _args) do
    Logger.info("Starting server on http://127.0.0.1:4221")
    Supervisor.start_link([{Task, fn -> Server.listen() end}], strategy: :one_for_one)
  end

  @spec listen :: ListenSocket
  def listen do
    {:ok, socket} = :gen_tcp.listen(4221, [:binary, active: false, reuseaddr: true])
    loop(socket)
  end

  defp loop(socket) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    # this is what gets us the concurrency
    Task.start(fn -> handle_client(client_socket) end)
    # and finally, tail recurse.
    loop(socket)
  end

  defp handle_client(client_socket) do
    # this is the boundary - naive assumption checks of a perfect world.
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, request} ->
        # logging - becasue reasons
        Logger.debug("#{inspect(request)}")

        # make the respone
        response = Server.Handler.handle(request)

        # return the reply
        reply(response, client_socket)

        # now close or recurse
        if response.close? do
          :gen_tcp.close(client_socket)
        else
          handle_client(client_socket)
        end

      {:error, :closed} ->
        :gen_tcp.close(client_socket)

      {:error, error} ->
        Logger.error("loop error: #{inspect(error)}")
    end
  end

  defp reply(response, client_socket) do
    response
    |> to_string()
    |> then(fn response -> :gen_tcp.send(client_socket, response) end)
  end

  @spec main(Keyword.t()) :: no_return()
  def main(opts) do
    # parse the opts
    {opts, _args, _invalid} = OptionParser.parse(opts, strict: [directory: :string])
    directory = Keyword.get(opts, :directory)

    # set the config
    Application.put_env(:codecrafters_http_server, :directory, directory)

    {:ok, _pid} = Application.ensure_all_started(:codecrafters_http_server)
    Process.sleep(:infinity)
  end
end
