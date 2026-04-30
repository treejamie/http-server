# https://hexdocs.pm/credo/config_file.html
%{
  configs: [
    %{
      name: "default",
      checks: %{
        enabled: [
          {Credo.Check.Readability.Specs, []}
        ],
        disabled: [
          # this means that `TabsOrSpaces` will not run
          {Credo.Check.Consistency.TabsOrSpaces, []}
        ]
      }
    }
  ]
}
