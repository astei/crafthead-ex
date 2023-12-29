defmodule Crafthead.Profile.MinecraftTest do
  use ExUnit.Case, async: true

  describe "get_skin_info/1" do
    test "returns skin information" do
      profile = %Crafthead.Profile.Minecraft{
        :id => "652a2bc4e8cd405db7b698156ee2dc09",
        :name => "tuxed",
        :properties => [
          %{
            "name" => "textures",
            "value" =>
              "ewogICJ0aW1lc3RhbXAiIDogMTcwMzgyNzIzMTg0OCwKICAicHJvZmlsZUlkIiA6ICI2NTJhMmJjNGU4Y2Q0MDVkYjdiNjk4MTU2ZWUyZGMwOSIsCiAgInByb2ZpbGVOYW1lIiA6ICJ0dXhlZCIsCiAgInRleHR1cmVzIiA6IHsKICAgICJTS0lOIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS9kOWM1MjcwMzUwOWM3MDcwNDczMGIyZDg4MmIzNjdjMTEyMWM2NGYzZDZmNmE5ZDEyNmU0N2IxZmU2NTY4MGI5IgogICAgfQogIH0KfQ=="
          }
        ]
      }

      expected_result = %{
        skin: %{
          url:
            "http://textures.minecraft.net/texture/d9c52703509c70704730b2d882b367c1121c64f3d6f6a9d126e47b1fe65680b9",
          model: :classic
        },
        cape: nil
      }

      assert Crafthead.Profile.Minecraft.get_skin_info(profile) == expected_result
    end

    test "returns cape information" do
      profile = %Crafthead.Profile.Minecraft{
        :id => "1ccef50bf6ae4542b1a9d434384a5b25",
        :name => "Jeff",
        :properties => [
          %{
            "name" => "textures",
            "value" =>
              "ewogICJ0aW1lc3RhbXAiIDogMTcwMzgyOTE5NjM0NCwKICAicHJvZmlsZUlkIiA6ICIxY2NlZjUwYmY2YWU0NTQyYjFhOWQ0MzQzODRhNWIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJKZWZmIiwKICAidGV4dHVyZXMiIDogewogICAgIlNLSU4iIDogewogICAgICAidXJsIiA6ICJodHRwOi8vdGV4dHVyZXMubWluZWNyYWZ0Lm5ldC90ZXh0dXJlL2Y3ZjdhNWFmYmY5NDZkYWUxOWZhMzhjMjIxZTMxMDM0NTE5YjE5OWViMWZkZTkwZTI0OTUxNzJlOWQ3ZDZhIgogICAgfSwKICAgICJDQVBFIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS85NTNjYWM4Yjc3OWZlNDEzODNlNjc1ZWUyYjg2MDcxYTcxNjU4ZjIxODBmNTZmYmNlOGFhMzE1ZWE3MGUyZWQ2IgogICAgfQogIH0KfQ=="
          }
        ]
      }

      expected_result = %{
        skin: %{
          url:
            "http://textures.minecraft.net/texture/f7f7a5afbf946dae19fa38c221e31034519b199eb1fde90e2495172e9d7d6a",
          model: :classic
        },
        cape:
          "http://textures.minecraft.net/texture/953cac8b779fe41383e675ee2b86071a71658f2180f56fbce8aa315ea70e2ed6"
      }

      assert Crafthead.Profile.Minecraft.get_skin_info(profile) == expected_result
    end
  end
end
