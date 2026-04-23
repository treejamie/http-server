defmodule Server.Response do
  defstruct method: nil,
            path: nil,
            params: %{},
            headers: %{},
            content_type: "text/plain",
            body: nil,
            status: nil

  def full_status(%__MODULE__{} = response) do
    "#{response.status} #{status_reason(response.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

defimpl String.Chars, for: Server.Response do
  def to_string(%Server.Response{} = r) do
    body =
      case r.body do
        nil -> ""
        body -> body
      end

    """
    HTTP/1.1 #{Server.Response.full_status(r)}\r
    Content-Type: #{r.content_type}\r
    Content-Length: #{String.length(body)}\r
    \r
    #{body}
    """
  end
end
