defmodule Server.Parser do
  alias Server.Response

  @supported_encodings [
    "gzip"
  ]

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
    headers =
      with [accept_header, accept_value] <- String.split(head, ": "),
           {res_header, res_value} <-
             header?(
               accept_header |> String.downcase(),
               accept_value |> String.downcase()
             ) do
        Map.put(headers, res_header, res_value)
      else
        _ -> headers
      end

    # and now recurse
    parse_headers(tail, headers)
  end

  defp parse_headers([], headers), do: headers

  # Accept-Encoding
  # Could be a list of comma seperated values or a string
  # so split it on commas and filter any unsupported values
  defp header?("accept-encoding", value) do
    value
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn value -> value in @supported_encodings end)
    |> List.first()
    |> case do
      nil -> nil
      val -> {"Content-Encoding", val}
    end
  end

  # I think this one has to stay as part of the codecrafters test suite
  defp header?("user-agent", ua), do: {"User-Agent", ua}

  defp header?(_, _), do: nil
end
