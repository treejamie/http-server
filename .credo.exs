# https://hexdocs.pm/credo/config_file.html
%{
  configs: [
    %{
      name: "default",
      checks: %{
        disabled: [
          # this means that `TabsOrSpaces` will not run
          {Credo.Check.Consistency.TabsOrSpaces, []}
        ]
      }
    }
  ]
}
