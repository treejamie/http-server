defmodule Server.Parser do
  @moduledoc """
  Transforms a plain text HTTP request into a Response.
  """
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

    # build a response from what we have
    %Response{
      method: method,
      path: path,
      close?: false,
      request_body: request_body
    }
    # pipe that through the headers
    |> parse_headers(header_lines)
  end

  defp parse_headers(response, [head | tail]) do
    response =
      with [accept_header, accept_value] <- String.split(head, ": "),
           response <-
             handle_header?(
               response,
               accept_header |> String.downcase(),
               accept_value |> String.downcase()
             ) do
        response
      else
        _ -> response
      end

    # and now recurse
    parse_headers(response, tail)
  end

  defp parse_headers(response, []), do: response

  # Accept-Encoding
  # Could be a list of comma seperated values or a string
  # so split it on commas and filter any unsupported values
  defp handle_header?(response, "accept-encoding", value) do
    value
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(fn value -> value in @supported_encodings end)
    |> List.first()
    |> case do
      nil -> response
      val -> put_in(response.headers["Content-Encoding"], val)
    end
  end

  # Connection: close
  # HTTP connections are persistant by default but
  # if a Connection: close header is present we will
  # need to close the connection.
  defp handle_header?(response, "connection", "close") do
    response.headers["Connection"]
    |> put_in("close")
    |> Map.put(:close?, true)
  end

  # I think this one has to stay as part of the codecrafters test suite
  defp handle_header?(response, "user-agent", ua) do
    put_in(response.headers["User-Agent"], ua)
  end

  defp handle_header?(response, _, _), do: response
end
