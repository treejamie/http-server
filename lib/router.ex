defmodule Server.Router do
  require Logger
  alias Server.Response

  def route(%Response{method: "GET", path: "/"} = response) do
    %{response | status: 200}
  end

  def route(%Response{method: "GET", path: "/files/" <> file} = response) do
    # TODO: harden against traversal attacks
    full_path =
      Path.join([
        Application.get_env(:codecrafters_http_server, :directory),
        file
      ])

    # now we are either 200 or 404
    case File.exists?(full_path) do
      false ->
        content = "Not Found: #{file}"

        %{
          response
          | body: content,
            status: 404,
            content_length: byte_size(content)
        }

      true ->
        file = File.read!(full_path)

        %{
          response
          | body: file,
            status: 200,
            content_length: byte_size(file),
            content_type: "application/octet-stream"
        }
    end
  end

  def route(%Response{method: "GET", path: "/echo/" <> content} = response) do
    %{response | body: content, status: 200}
  end

  def route(%Response{method: "GET", path: "/user-agent"} = response) do
    %{response | body: response.headers["User-Agent"], status: 200}
  end

  def route(response) do
    %{response | body: "Not Found", status: 404}
  end
end
