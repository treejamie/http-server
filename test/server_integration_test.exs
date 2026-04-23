defmodule Server.IntegrationTest do
  use ExUnit.Case

  @port 4221

  defp request(raw) do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", @port, [:binary, active: false])
    :ok = :gen_tcp.send(socket, raw)
    {:ok, response} = :gen_tcp.recv(socket, 0, 5_000)
    :gen_tcp.close(socket)
    response
  end

  test "GET / returns 200 status" do
    response = request("GET / HTTP/1.1\r\nHost: localhost:4221\r\n\r\n")
    assert response =~ "HTTP/1.1 200"
  end

  test "GET /echo/hello returns 200 with body" do
    response = request("GET /echo/hello HTTP/1.1\r\nHost: localhost\r\n\r\n")
    assert response =~ "HTTP/1.1 200"
    assert response =~ "Content-Type: text/plain"
    assert response =~ "hello"
    assert response =~ "Content-Length: 5"
  end

  test "unknown route returns 404" do
    response = request("GET /unknown HTTP/1.1\r\nHost: localhost\r\n\r\n")
    assert response =~ "Content-Type: text/plain"
    assert response =~ "HTTP/1.1 404"
  end
end
