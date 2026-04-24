defmodule Server.Router.Tests do
  use ExUnit.Case

  describe "Router.route/1" do
    test "POST /files/<filename> returns 201" do
      expected =
        "POST /files/number HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\nContent-Type: application/octet-stream\r\nContent-Length: 5\r\n\r\n12345"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 201
    end

    test "GET /files/carrot.jpeg returns 404" do
      expected =
        "GET /files/carrot.jpeg HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 404
      assert expected.content_type == "text/plain"
    end

    test "GET /files/ham.jpg returns 200" do
      expected =
        "GET /files/ham.jpeg HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 200
      assert expected.content_type == "application/octet-stream"
      assert expected.content_length == 5919
    end

    test "GET /user-agent returns 200" do
      expected =
        "GET / HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 200
    end

    test "GET / returns 200" do
      expected =
        "GET / HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 200
    end

    test "GET /get/abc puts abc in the body" do
      expected =
        "GET /echo/abc HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 200
    end
  end
end
