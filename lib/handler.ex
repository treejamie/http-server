defmodule Server.Handler do
  @moduledoc """
  A very simple handler that takes a request string and returns a response
  """

  @spec handle(String.t()) :: Server.Response.t()
  def handle(request) do
    request
    |> Server.Parser.parse()
    |> Server.Router.route()
  end
end
