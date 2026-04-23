defmodule Server.ParserTest do
  use ExUnit.Case

  describe "Parser.parse/1" do
    test "parses a request string as expected" do
      expected =
        "GET /echo/abc HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()

      assert %Server.Response{
               method: "GET",
               path: "/echo/abc",
               params: %{},
               headers: %{},
               content_type: "text/plain",
               body: nil,
               status: nil
             } == expected
    end
  end
end
