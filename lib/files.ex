defmodule Server.Files do
  @moduledoc """
  For processing and handling files
  """

  @spec write_file(String.t(), binary()) :: :ok | {:error, File.posix()}
  def write_file(filename, content) do
    build_path(filename)
    |> Path.safe_relative()
    |> case do
      {:ok, path} ->
        File.write(path, content)

      _ ->
        {:error, :unsafe_or_invalid_path}
    end
  end

  @spec read_file(String.t()) :: {:ok, binary} | {:error, File.posix()}
  def read_file(filename) do
    build_path(filename)
    |> Path.safe_relative()
    |> case do
      {:ok, path} ->
        File.read(path)

      _ ->
        {:error, :unsafe_or_invalid_path}
    end
  end

  def build_path(filename) do
    Path.join([
      Application.get_env(:codecrafters_http_server, :directory),
      filename
    ])
  end
end
