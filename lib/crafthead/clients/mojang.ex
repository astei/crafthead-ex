defmodule Crafthead.Clients.Mojang do
  alias Crafthead.Cache

  use Nebulex.Caching

  @username_ttl :timer.hours(1)
  @profile_ttl :timer.hours(24)

  @username_to_uuid_mapping_url "https://api.mojang.com/users/profiles/minecraft/"
  @uuid_to_profile_url "https://sessionserver.mojang.com/session/minecraft/profile/"
  @textures_base_url "https://textures.minecraft.net/texture/"

  @decorate cacheable(
              cache: Cache,
              key_generator: {String, :downcase, [username]},
              opts: [ttl: @username_ttl]
            )
  def username_to_uuid(username) do
    url = @username_to_uuid_mapping_url <> username <> "?unsigned=false"

    with {:ok, resp} <- Req.get(url) do
      case resp.status do
        200 -> {:ok, resp.body["id"]}
        404 -> {:error, :not_found}
        429 -> {:error, :too_many_requests}
        500 -> {:error, :internal_server_error}
        503 -> {:error, :service_unavailable}
        _ -> {:error, :unknown}
      end
    end
  end

  @decorate cacheable(cache: Cache, key: uuid, opts: [ttl: @profile_ttl])
  def uuid_to_profile(uuid) do
    url = @uuid_to_profile_url <> uuid

    with {:ok, resp} <- Req.get(url) do
      case resp.status do
        200 -> {:ok, Crafthead.Profile.Minecraft.new(resp.body)}
        204 -> {:error, :not_found}
        404 -> {:error, :not_found}
        429 -> {:error, :too_many_requests}
        500 -> {:error, :internal_server_error}
        503 -> {:error, :service_unavailable}
        _ -> {:error, :unknown}
      end
    end
  end

  @decorate cacheable(
              cache: Cache,
              key_generator: {Crafthead.Util.Request, :get_texture_id, [texture_id_or_url]},
              opts: [ttl: @profile_ttl]
            )
  def fetch_skin_from_texture_url(texture_id_or_url) do
    texture_url = @textures_base_url <> Crafthead.Util.Request.get_texture_id(texture_id_or_url)

    with {:ok, resp} <- Req.get(texture_url) do
      case resp.status do
        200 -> {:ok, resp.body}
        404 -> {:error, :not_found}
        _ -> {:error, :unknown}
      end
    end
  end
end
