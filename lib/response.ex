defmodule Server.Response do
  @moduledoc """
  The Response struct is the central idea in the http server
  """
  @type t :: %__MODULE__{
          method: String.t() | nil,
          path: String.t() | nil,
          params: map(),
          headers: map(),
          content_length: non_neg_integer() | nil,
          content_type: String.t(),
          close?: boolean(),
          body: iodata() | nil,
          status: non_neg_integer() | nil,
          request_body: binary() | nil
        }
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

  @spec full_status(__MODULE__.t()) :: String.t()
  def full_status(%__MODULE__{} = response) do
    "#{response.status} #{status_reason(response.status)}"
  end

  @spec gzip?(__MODULE__.t()) :: bool
  def gzip?(%__MODULE__{} = response) do
    case Map.get(response.headers, "Content-Encoding") do
      "gzip" -> true
      _ -> false
    end
  end

  @doc """
  If we need to close the connection. Send the header
  """
  @spec maybe_connection?(__MODULE__.t()) :: String.t()
  def maybe_connection?(response) do
    case response.close? do
      true -> "Connection: close\r\n"
      false -> ""
    end
  end

  @doc """
  If there's content encoding, show the header
  """
  @spec maybe_content_encoding?(map()) :: String.t()
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
  @spec get_body(Server.Response.t()) :: String.t() | iodata()
  def get_body(response) do
    # body could be nil, so defend against taht
    body = response.body || ""

    case Server.Response.gzip?(response) do
      true -> :zlib.gzip(body)
      false -> body
    end
  end

  @spec to_string(Server.Response.t()) :: String.t()
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
