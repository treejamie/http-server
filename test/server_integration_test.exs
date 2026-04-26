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

  describe "headers" do
    test "when accept-encoding is present as a series of comma seperate values, we send back a validContent-Encoding" do
      response =
        request(
          "GET /echo/strawberry HTTP/1.1\r\nHost: localhost:4221\r\nAccept-Encoding: encoding-1, gzip, encoding-2\r\n\r\n"
        )

      assert response =~ "Content-Encoding: gzip"
    end

    test "when accept-encoding is present as a single item, we send back Content-Encoding" do
      response =
        request(
          "GET /echo/foo HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: foo\r\nAccept: */*\r\nAccept-Encoding: gzip\r\n\r\n"
        )

      assert response =~ "Content-Encoding: gzip"
    end
  end

  describe "files" do
    test "POST with request body and we write a file" do
      response =
        request(
          "POST /files/number HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\nContent-Type: application/octet-stream\r\nContent-Length: 5\r\n\r\n12345"
        )

      assert response =~ "HTTP/1.1 201"
    end

    test "GET 200 and a file when it exists" do
      response =
        request(
          "GET /files/ham.jpeg HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        )

      assert response =~ "HTTP/1.1 200"
      assert response =~ "application/octet-stream"
    end
  end

  describe "concurrency" do
    test "handles concurrent connections" do
      tasks =
        for _ <- 1..20 do
          Task.async(fn -> request("GET /echo/hello HTTP/1.1\r\nHost: localhost\r\n\r\n") end)
        end

      results = Task.await_many(tasks)

      assert Enum.all?(results, fn r -> r =~ "HTTP/1.1 200" end)
    end
  end

  describe "basics" do
    test "GET /user-agent returns the correct user agent" do
      request =
        "GET /user-agent HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: foobar/1.2.3\r\nAccept: */*\r\n\r\n"

      response = request(request)
      assert response =~ "HTTP/1.1 200"
      assert response =~ "foobar/1.2.3"
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
end
