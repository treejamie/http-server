defmodule Server.Router do
  @moduledoc """
  Maps http responses through defined routes.

  There's a conflict in being the server and the application and having routes does
  actually blur the line a little so consider this module as a very crude interface
  to validate http behavior through integration tests.

  """
  require Logger
  alias Server.Files
  alias Server.Response

  def route(%Response{method: "GET", path: "/"} = response) do
    %{response | status: 200}
  end

  def route(%Response{method: "POST", path: "/files/" <> filename} = response) do
    case Files.write_file(filename, response.request_body) do
      :ok -> %{response | status: 201}
      _ -> %{response | status: 500}
    end
  end

  def route(%Response{method: "GET", path: "/files/" <> filename} = response) do
    # now we are either 200 or 404
    case Files.read_file(filename) do
      {:ok, content} ->
        %{
          response
          | body: content,
            status: 200,
            content_length: byte_size(content),
            content_type: "application/octet-stream"
        }

      _ ->
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
