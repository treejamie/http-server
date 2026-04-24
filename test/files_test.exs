defmodule Server.FilesTest do
  use ExUnit.Case

  import Server.Files, only: [write_file: 2, read_file: 1]

  describe "read_file/1" do
    test "happy path - reads existing file" do
      {:ok, content} = read_file("ham.jpeg")
      assert is_binary(content)
      assert byte_size(content) > 0
    end

    test "sad path - file does not exist" do
      assert {:error, :enoent} = read_file("nonexistent.jpeg")
    end
  end

  describe "write_file/2" do
    test "happy path - writes file successfully" do
      assert :ok = write_file("test_output.txt", "some content")
      # cleanup - full path as this doesn't go through server codepath
      File.rm("data/test_output.txt")
    end

    test "sad path - directory does not exist" do
      assert {:error, :enoent} = write_file("nonexistent_dir/test.jpeg", "some content")
    end
  end
end
