defmodule Server.Parser do
  alias Server.Response

  def parse(request) do
    # Split into lines first
    [request_line | _header_lines] = String.split(request, "\r\n", trim: true)

    # Then split the request line on spaces
    [method, path, _version] = String.split(request_line, " ")

    # and now return a response
    %Response{
      method: method,
      path: path
    }
  end
end
