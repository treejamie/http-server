defmodule Server.ParserTest do
  use ExUnit.Case

  describe "parses close headers" do
    test "when no close header is present, close? is false " do
      expected =
        "GET /echo/abc HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()

      assert expected.close? == false
    end

    test "when close header is present, close? is true" do
      expected =
        "GET /echo/abc HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nConnection: close\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()

      assert expected.close? == true
    end
  end

  describe "parses compression headers" do
    test "if there are no valid compression headers, we don't set the header" do
      expected =
        "GET /echo/blueberry HTTP/1.1\r\nHost: localhost:4221\r\nAccept-Encoding: encoding-1, encoding-2\r\n\r\n"
        |> Server.Parser.parse()

      refute Map.get(expected.headers, "Content-Encoding")
    end

    test "multiple compression headers maybe present, but we only accept valid ones" do
      expected =
        "GET /echo/foo HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: foo\r\nAccept: */*\r\nAccept-Encoding: gzip, encoding-1, encoding-2, encoding-3\r\n\r\n"
        |> Server.Parser.parse()

      assert expected.headers["Content-Encoding"] == "gzip"
    end

    test "when Accept-Encoding headers are present we send back Content-Encoding" do
      expected =
        "GET /echo/foo HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: foo\r\nAccept: */*\r\nAccept-Encoding: gzip\r\n\r\n"
        |> Server.Parser.parse()

      assert expected.headers["Content-Encoding"] == "gzip"
    end
  end

  describe "Parser.parse/1" do
    # Construct, reduce, convert
    test "parses content correctly" do
      expected =
        "POST /files/number HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: curl/7.64.1\r\nAccept: */*\r\nContent-Type: application/octet-stream\r\nContent-Length: 5\r\n\r\n12345"
        |> Server.Parser.parse()

      assert expected.request_body == "12345"
    end

    test "parses headers correctly" do
      expected =
        "GET /user-agent HTTP/1.1\r\nHost: localhost:4221\r\nUser-Agent: foobar/1.2.3\r\nAccept: */*\r\n\r\n"
        |> Server.Parser.parse()

      assert expected.headers == %{
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
