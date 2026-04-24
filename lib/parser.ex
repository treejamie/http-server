defmodule Server.Parser do
  alias Server.Response

  def parse(request) do
    # split out request body first as that's \r\n\r\n
    [request | [request_body]] = String.split(request, "\r\n\r\n")

    # next, split into lines
    [request_line | header_lines] = String.split(request, "\r\n", trim: true)

    # finally, split the request line on spaces so we have our headers
    [method, path, _version] = String.split(request_line, " ")

    # now parse those headers
    headers = parse_headers(header_lines, %{})

    # and return a response
    %Response{
      method: method,
      path: path,
      headers: headers,
      request_body: request_body
    }
  end

  defp parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")

    # now build the headers by adding key and value onto the map
    headers = Map.put(headers, key, value)

    # and now recurse
    parse_headers(tail, headers)
  end

  defp parse_headers([], headers), do: headers
end
