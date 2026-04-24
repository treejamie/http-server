defmodule Server.Router do
  require Logger
  alias Server.Response
  alias Server.Files

  def route(%Response{method: "GET", path: "/"} = response) do
    %{response | status: 200}
  end

  def route(%Response{method: "POST", path: "/files/" <> filename} = response) do
    with :ok <- Files.write_file(filename, response.request_body) do
      %{response | status: 201}
    else
      {:error, _} ->
        %{response | status: 500}
    end
  end

  def route(%Response{method: "GET", path: "/files/" <> filename} = response) do
    # now we are either 200 or 404
    with {:ok, content} <- Files.read_file(filename) do
      %{
        response
        | body: content,
          status: 200,
          content_length: byte_size(content),
          content_type: "application/octet-stream"
      }
    else
      {:error, _} ->
        content = "Not Found: #{filename}"

        %{
          response
          | body: content,
            status: 404,
            content_length: byte_size(content)
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
