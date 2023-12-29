defmodule Crafthead.Util.Request do
  import Bitwise

  @mojang_uuid_regex ~r/^[0-9a-f]{32}$/
  @regular_uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @minecraft_texture_base_url ~r/^(?>https?:\/\/textures\.minecraft\.net\/texture\/)?([0-9a-f]{64})$/

  @doc ~S"""
  Given the Minecraft profile `entity`, determine if it refers to a UUID or a username.

  ## Examples

    iex> Crafthead.Util.Request.what_entity("1ccef50bf6ae4542b1a9d434384a5b25")
    {:uuid, "1ccef50bf6ae4542b1a9d434384a5b25"}
    iex> Crafthead.Util.Request.what_entity("4525ca19-5825-4774-bb90-a004de1460c3")
    {:uuid, "4525ca1958254774bb90a004de1460c3"}
    iex> Crafthead.Util.Request.what_entity("tuxed")
    {:username, "tuxed"}
    iex> Crafthead.Util.Request.what_entity("LadyAgnes")
    {:username, "ladyagnes"}

  """
  def what_entity(entity) do
    cond do
      Regex.match?(@mojang_uuid_regex, entity) -> {:uuid, entity}
      Regex.match?(@regular_uuid_regex, entity) -> {:uuid, String.replace(entity, "-", "")}
      true -> {:username, String.downcase(entity)}
    end
  end

  @doc ~S"""
  Given the Minecraft texture ID or URL `texture_id_or_url`, return the texture ID.

  ## Examples

    iex> Crafthead.Util.Request.get_texture_id("d9c52703509c70704730b2d882b367c1121c64f3d6f6a9d126e47b1fe65680b9")
    "d9c52703509c70704730b2d882b367c1121c64f3d6f6a9d126e47b1fe65680b9"
    iex> Crafthead.Util.Request.get_texture_id("http://textures.minecraft.net/texture/d9c52703509c70704730b2d882b367c1121c64f3d6f6a9d126e47b1fe65680b9")
    "d9c52703509c70704730b2d882b367c1121c64f3d6f6a9d126e47b1fe65680b9"
    iex> Crafthead.Util.Request.get_texture_id("https://textures.minecraft.net/texture/d9c52703509c70704730b2d882b367c1121c64f3d6f6a9d126e47b1fe65680b9")
    "d9c52703509c70704730b2d882b367c1121c64f3d6f6a9d126e47b1fe65680b9"
    iex> Crafthead.Util.Request.get_texture_id("garbage")
    nil

  """
  def get_texture_id(texture_id_or_url) do
    case Regex.match?(@minecraft_texture_base_url, texture_id_or_url) do
      true -> Regex.replace(@minecraft_texture_base_url, texture_id_or_url, "\\1")
      false -> nil
    end
  end

  @doc ~S"""
  Given the string, return the UUIDv3 that would be generated by Java'x `UUID.nameUUIDFromBytes()` method.

  ## Examples

    iex> Crafthead.Util.Request.java_v3("OfflinePlayer:tuxed")
    "708f6260183d3912bbde5e279a5e739a"

  """
  def java_v3(username) do
    # Java's UUID class uses a non-comformant mechanism for generating v3 UUIDs (specfically, it doesn't generate v3 UUIDs
    # with a namespace), so we can't just use the UUID module from Hex.

    # We need to extract the first six bytes (to save for later), the following three bytes individually (indices 6, 7, and 8 - 7 is unmodified),
    # and save the remaining bytes (indices 9 and up).
    <<f6::binary-size(6), f7, f8, f9, rest::binary>> = :crypto.hash(:md5, username)

    (f6 <> <<bor(band(f7, 0x0F), 0x30)>> <> <<f8>> <> <<bor(band(f9, 0x3F), 0x80)>> <> rest)
    |> Base.encode16(case: :lower)
  end
end
