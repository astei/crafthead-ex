defmodule CraftheadWeb.UtilTest do
  @always_renders_steve_uuid "fffffff0fffffff0fffffff0fffffff0"

  use CraftheadWeb.ConnCase

  alias CraftheadWeb.Util, as: WebUtil

  import Mock

  describe "get_profile_for_entity/1 uuid entity" do
    test "returns not found for a v3 UUID" do
      with_mock Crafthead.Clients.Mojang, uuid_to_profile: fn _ -> {:error, :dont_reach_me} end do
        assert {:error, :not_found} =
                 WebUtil.get_profile_for_entity({:uuid, "708f6260183d3912bbde5e279a5e739a"})

        assert_not_called(
          Crafthead.Clients.Mojang.uuid_to_profile("708f6260183d3912bbde5e279a5e739a")
        )
      end
    end

    test "passes not found errors through" do
      with_mock Crafthead.Clients.Mojang, uuid_to_profile: fn _ -> {:error, :not_found} end do
        assert {:error, :not_found} =
                 WebUtil.get_profile_for_entity({:uuid, "1ccef50bf6ae4542b1a9d434384a5b25"})

        assert_called(
          Crafthead.Clients.Mojang.uuid_to_profile("1ccef50bf6ae4542b1a9d434384a5b25")
        )
      end
    end

    test "passes errors through" do
      with_mock Crafthead.Clients.Mojang, uuid_to_profile: fn _ -> {:error, :some_error} end do
        assert {:error, :some_error} =
                 WebUtil.get_profile_for_entity({:uuid, "1ccef50bf6ae4542b1a9d434384a5b25"})

        assert_called(
          Crafthead.Clients.Mojang.uuid_to_profile("1ccef50bf6ae4542b1a9d434384a5b25")
        )
      end
    end

    test "will fetch a profile with a valid UUID" do
      with_mock Crafthead.Clients.Mojang,
        uuid_to_profile: fn _ ->
          {:ok,
           %Crafthead.Profile.Minecraft{
             :id => "1ccef50bf6ae4542b1a9d434384a5b25",
             :name => "Jeff",
             :properties => [
               %{
                 "name" => "textures",
                 "value" =>
                   "ewogICJ0aW1lc3RhbXAiIDogMTcwMzgyOTE5NjM0NCwKICAicHJvZmlsZUlkIiA6ICIxY2NlZjUwYmY2YWU0NTQyYjFhOWQ0MzQzODRhNWIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJKZWZmIiwKICAidGV4dHVyZXMiIDogewogICAgIlNLSU4iIDogewogICAgICAidXJsIiA6ICJodHRwOi8vdGV4dHVyZXMubWluZWNyYWZ0Lm5ldC90ZXh0dXJlL2Y3ZjdhNWFmYmY5NDZkYWUxOWZhMzhjMjIxZTMxMDM0NTE5YjE5OWViMWZkZTkwZTI0OTUxNzJlOWQ3ZDZhIgogICAgfSwKICAgICJDQVBFIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS85NTNjYWM4Yjc3OWZlNDEzODNlNjc1ZWUyYjg2MDcxYTcxNjU4ZjIxODBmNTZmYmNlOGFhMzE1ZWE3MGUyZWQ2IgogICAgfQogIH0KfQ=="
               }
             ]
           }}
        end do
        assert {:ok, _} =
                 WebUtil.get_profile_for_entity({:uuid, "1ccef50bf6ae4542b1a9d434384a5b25"})

        assert_called(
          Crafthead.Clients.Mojang.uuid_to_profile("1ccef50bf6ae4542b1a9d434384a5b25")
        )
      end
    end
  end

  describe "get_profile_for_entity/1 username entity" do
    test "passes errors through" do
      with_mock Crafthead.Clients.Mojang, username_to_uuid: fn _ -> {:error, :some_error} end do
        assert {:error, :some_error} =
                 WebUtil.get_profile_for_entity({:username, "tuxed"})

        assert_called(Crafthead.Clients.Mojang.username_to_uuid("tuxed"))
      end
    end

    test "eventually calls profile lookup for a UUID" do
      with_mock Crafthead.Clients.Mojang,
        username_to_uuid: fn _ -> {:ok, "1ccef50bf6ae4542b1a9d434384a5b25"} end,
        uuid_to_profile: fn _ ->
          {:ok,
           %Crafthead.Profile.Minecraft{
             :id => "1ccef50bf6ae4542b1a9d434384a5b25",
             :name => "Jeff",
             :properties => [
               %{
                 "name" => "textures",
                 "value" =>
                   "ewogICJ0aW1lc3RhbXAiIDogMTcwMzgyOTE5NjM0NCwKICAicHJvZmlsZUlkIiA6ICIxY2NlZjUwYmY2YWU0NTQyYjFhOWQ0MzQzODRhNWIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJKZWZmIiwKICAidGV4dHVyZXMiIDogewogICAgIlNLSU4iIDogewogICAgICAidXJsIiA6ICJodHRwOi8vdGV4dHVyZXMubWluZWNyYWZ0Lm5ldC90ZXh0dXJlL2Y3ZjdhNWFmYmY5NDZkYWUxOWZhMzhjMjIxZTMxMDM0NTE5YjE5OWViMWZkZTkwZTI0OTUxNzJlOWQ3ZDZhIgogICAgfSwKICAgICJDQVBFIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS85NTNjYWM4Yjc3OWZlNDEzODNlNjc1ZWUyYjg2MDcxYTcxNjU4ZjIxODBmNTZmYmNlOGFhMzE1ZWE3MGUyZWQ2IgogICAgfQogIH0KfQ=="
               }
             ]
           }}
        end do
        assert {:ok, _} =
                 WebUtil.get_profile_for_entity({:username, "Jeff"})

        assert_called(Crafthead.Clients.Mojang.username_to_uuid("Jeff"))

        assert_called(
          Crafthead.Clients.Mojang.uuid_to_profile("1ccef50bf6ae4542b1a9d434384a5b25")
        )
      end
    end
  end

  describe "get_potentially_fake_profile_from_entity/1 uuid entity" do
    test "returns a fake profile if the remote profile isn't found" do
      with_mock WebUtil, [:passthrough], get_profile_for_entity: fn _ -> {:error, :not_found} end do
        assert {:ok, profile} =
                 WebUtil.get_potentially_fake_profile_from_entity(
                   {:uuid, "708f6260183d3912bbde5e279a5e739a"}
                 )

        assert profile == %Crafthead.Profile.Minecraft{
                 id: "708f6260183d3912bbde5e279a5e739a",
                 name: "708f6260183d3912bbde5e279a5e739a",
                 properties: []
               }

        assert_called(WebUtil.get_profile_for_entity({:uuid, "708f6260183d3912bbde5e279a5e739a"}))
      end
    end

    test "passes on any other error" do
      with_mock WebUtil, [:passthrough], get_profile_for_entity: fn _ -> {:error, :some_error} end do
        assert {:error, :some_error} =
                 WebUtil.get_potentially_fake_profile_from_entity(
                   {:uuid, "708f6260183d3912bbde5e279a5e739a"}
                 )

        assert_called(WebUtil.get_profile_for_entity({:uuid, "708f6260183d3912bbde5e279a5e739a"}))
      end
    end

    test "passes on a successfully-retrieved profile" do
      with_mock WebUtil, [:passthrough],
        get_profile_for_entity: fn _ ->
          {:ok,
           %Crafthead.Profile.Minecraft{
             :id => "1ccef50bf6ae4542b1a9d434384a5b25",
             :name => "Jeff",
             :properties => [
               %{
                 "name" => "textures",
                 "value" =>
                   "ewogICJ0aW1lc3RhbXAiIDogMTcwMzgyOTE5NjM0NCwKICAicHJvZmlsZUlkIiA6ICIxY2NlZjUwYmY2YWU0NTQyYjFhOWQ0MzQzODRhNWIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJKZWZmIiwKICAidGV4dHVyZXMiIDogewogICAgIlNLSU4iIDogewogICAgICAidXJsIiA6ICJodHRwOi8vdGV4dHVyZXMubWluZWNyYWZ0Lm5ldC90ZXh0dXJlL2Y3ZjdhNWFmYmY5NDZkYWUxOWZhMzhjMjIxZTMxMDM0NTE5YjE5OWViMWZkZTkwZTI0OTUxNzJlOWQ3ZDZhIgogICAgfSwKICAgICJDQVBFIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS85NTNjYWM4Yjc3OWZlNDEzODNlNjc1ZWUyYjg2MDcxYTcxNjU4ZjIxODBmNTZmYmNlOGFhMzE1ZWE3MGUyZWQ2IgogICAgfQogIH0KfQ=="
               }
             ]
           }}
        end do
        assert {:ok, profile} =
                 WebUtil.get_potentially_fake_profile_from_entity(
                   {:uuid, "708f6260183d3912bbde5e279a5e739a"}
                 )

        assert profile.name == "Jeff"

        assert_called(WebUtil.get_profile_for_entity({:uuid, "708f6260183d3912bbde5e279a5e739a"}))
      end
    end
  end

  describe "get_potentially_fake_profile_from_entity/1 username entity" do
    test "returns a fake profile if the username isn't found" do
      with_mock WebUtil, [:passthrough], get_profile_for_entity: fn _ -> {:error, :not_found} end do
        assert {:ok, profile} =
                 WebUtil.get_potentially_fake_profile_from_entity({:username, "tuxed"})

        assert profile == %Crafthead.Profile.Minecraft{
                 id: "708f6260183d3912bbde5e279a5e739a",
                 name: "tuxed",
                 properties: []
               }

        assert_called(WebUtil.get_profile_for_entity({:username, "tuxed"}))
      end
    end

    test "passes on any other error" do
      with_mock WebUtil, [:passthrough], get_profile_for_entity: fn _ -> {:error, :some_error} end do
        assert {:error, :some_error} =
                 WebUtil.get_potentially_fake_profile_from_entity({:username, "tuxed"})

        assert_called(WebUtil.get_profile_for_entity({:username, "tuxed"}))
      end
    end

    test "passes on a successfully-retrieved profile" do
      with_mock WebUtil, [:passthrough],
        get_profile_for_entity: fn _ ->
          {:ok,
           %Crafthead.Profile.Minecraft{
             :id => "1ccef50bf6ae4542b1a9d434384a5b25",
             :name => "Jeff",
             :properties => [
               %{
                 "name" => "textures",
                 "value" =>
                   "ewogICJ0aW1lc3RhbXAiIDogMTcwMzgyOTE5NjM0NCwKICAicHJvZmlsZUlkIiA6ICIxY2NlZjUwYmY2YWU0NTQyYjFhOWQ0MzQzODRhNWIyNSIsCiAgInByb2ZpbGVOYW1lIiA6ICJKZWZmIiwKICAidGV4dHVyZXMiIDogewogICAgIlNLSU4iIDogewogICAgICAidXJsIiA6ICJodHRwOi8vdGV4dHVyZXMubWluZWNyYWZ0Lm5ldC90ZXh0dXJlL2Y3ZjdhNWFmYmY5NDZkYWUxOWZhMzhjMjIxZTMxMDM0NTE5YjE5OWViMWZkZTkwZTI0OTUxNzJlOWQ3ZDZhIgogICAgfSwKICAgICJDQVBFIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS85NTNjYWM4Yjc3OWZlNDEzODNlNjc1ZWUyYjg2MDcxYTcxNjU4ZjIxODBmNTZmYmNlOGFhMzE1ZWE3MGUyZWQ2IgogICAgfQogIH0KfQ=="
               }
             ]
           }}
        end do
        assert {:ok, profile} =
                 WebUtil.get_potentially_fake_profile_from_entity({:username, "Jeff"})

        assert profile.name == "Jeff"

        assert_called(WebUtil.get_profile_for_entity({:username, "Jeff"}))
      end
    end

    for entity <- ["char", "MHF_Steve"] do
      test "returns a fake profile for #{entity}" do
        with_mock WebUtil, [:passthrough],
          get_profile_for_entity: fn _ -> {:error, :some_error} end do
          assert {:ok, profile} =
                   WebUtil.get_potentially_fake_profile_from_entity({:username, unquote(entity)})

          assert profile == %Crafthead.Profile.Minecraft{
                   id: @always_renders_steve_uuid,
                   name: unquote(entity),
                   properties: []
                 }

          assert_not_called(WebUtil.get_profile_for_entity({:username, "char"}))
        end
      end
    end
  end
end
