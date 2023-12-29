defmodule Crafthead.Util.Request do
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
end
