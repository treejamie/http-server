defmodule Server.ParserTest do
  use ExUnit.Case

  describe "Parser.parse/1" do
    test "parses headers correctly" do
      expected =
        "GET /user-agent HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: foobar/1.2.3\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()

      assert expected.headers == %{
               "Accept" => "*/*",
               "Host" => "localhost:4221",
               "User-Agent" => "foobar/1.2.3"
             }
    end

    test "parses a request string as expected" do
      expected =
        "GET /echo/abc HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()

      assert expected.method == "GET"
      assert expected.path == "/echo/abc"
      assert expected.content_type == "text/plain"
    end
  end
end
