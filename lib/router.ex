defmodule Server.Router do
  alias Server.Response

  def route(%Response{method: "GET", path: "/"} = response) do
    %{response | status: 200}
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
