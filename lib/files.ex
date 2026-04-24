defmodule Server.Files do
  @spec write_file(String.t(), binary()) :: :ok | {:error, File.posix()}
  def write_file(filename, content) do
    build_path(filename)
    |> File.write(content)
  end

  @spec read_file(String.t()) :: {:ok, binary} | {:error, File.posix()}
  def read_file(filename) do
    build_path(filename)
    |> File.read()
  end

  def build_path(filename) do
    # TODO: harden against traversal attacks
    Path.join([
      Application.get_env(:codecrafters_http_server, :directory),
      filename
    ])
  end
end
