defmodule Server.Handler do
  @doc """
  A very simple handler that takes a request string and returns a response
  """
  def handle(request) do
    request
    |> Server.Parser.parse()
    |> Server.Router.route()
  end
end
