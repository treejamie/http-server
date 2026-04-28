defmodule Server.Response do
  defstruct method: nil,
            path: nil,
            params: %{},
            headers: %{},
            content_length: nil,
            content_type: "text/plain",
            close?: false,
            body: nil,
            status: nil,
            request_body: nil

  def full_status(%__MODULE__{} = response) do
    "#{response.status} #{status_reason(response.status)}"
  end

  def gzip?(%__MODULE__{} = response) do
    case Map.get(response.headers, "Content-Encoding") do
      "gzip" -> true
      _ -> false
    end
  end

  @doc """
  If we need to close the connection. Send the header
  """
  def maybe_connection?(response) do
    case response.close? do
      true -> "Connection: close\r\n"
      false -> ""
    end
  end

  @doc """
  If there's content encoding, show the header
  """
  def maybe_content_encoding?(headers) do
    case Map.get(headers, "Content-Encoding") do
      nil -> ""
      value -> "Content-Encoding: #{value}\r\n"
    end
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      418 => "I'm a teapot",
      500 => "Internal Server Error"
    }[code]
  end
end

defimpl String.Chars, for: Server.Response do
  def get_body(response) do
    # body could be nil, so defend against taht
    body = response.body || ""

    case Server.Response.gzip?(response) do
      true -> :zlib.gzip(body)
      false -> body
    end
  end

  def to_string(%Server.Response{} = response) do
    # some parts needs to be calculated
    body = get_body(response)
    content_length = byte_size(body)

    # now build the response...
    "HTTP/1.1 #{Server.Response.full_status(response)}\r\n" <>
      "Content-Type: #{response.content_type}\r\n" <>
      Server.Response.maybe_connection?(response) <>
      Server.Response.maybe_content_encoding?(response.headers) <>
      "Content-Length: #{content_length}\r\n" <>
      "\r\n" <>
      body
  end
end
