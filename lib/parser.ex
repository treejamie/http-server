defmodule Server.Parser do
  alias Server.Response

  def parse(request) do
    # Split into lines first
    [request_line | header_lines] = String.split(request, "\r\n", trim: true)

    # Then split the request line on spaces
    [method, path, _version] = String.split(request_line, " ")

    # now parse the headers
    headers = parse_headers(header_lines, %{})

    # and now return a response
    %Response{
      method: method,
      path: path,
      headers: headers
    }
  end

  defp parse_headers([head | tail], headers) do
    # split up the head into key values - this is ok, becasue there's a spec for HTTP headers
    # and even if this one didn't match, we'd return a 400 Bad Request
    [key, value] = String.split(head, ": ")

    # now build the headers by adding key and value onto the map
    headers = Map.put(headers, key, value)

    # and now recurse
    parse_headers(tail, headers)
  end

  defp parse_headers([], headers), do: headers
end
