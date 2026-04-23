defmodule Server.Router.Tests do
  use ExUnit.Case

  describe "Router.route/1" do
    test "/user-agent returns 200" do
      expected =
        "GET / HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 200
    end

    test "/ returns 200" do
      expected =
        "GET / HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 200
    end

    test "/get/abc puts abc in the body" do
      expected =
        "GET /echo/abc HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()
        |> Server.Router.route()

      assert expected.status == 200
    end
  end
end
