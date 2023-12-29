defmodule CraftheadWeb.SkinController do
  alias Crafthead.Clients.Mojang
  alias Crafthead.Profile.Minecraft
  alias Crafthead.Util.Request

  use CraftheadWeb, :controller

  action_fallback CraftheadWeb.FallbackControlle

  def show(conn, %{"entity" => raw_entity}) do
    entity = raw_entity |> Request.what_entity()

    with {:ok, profile} <- get_profile(entity),
         texture_info <- Minecraft.get_skin_info(profile) do
      if Map.has_key?(texture_info, :skin) do
        with {:ok, skin} <- Mojang.fetch_skin_from_texture_url(texture_info.skin.url) do
          conn
          |> put_resp_header("cache-control", "public, max-age=86400")
          |> put_resp_header("content-type", "image/png")
          |> send_resp(200, skin)
        end
      else
        # need to show a fallback, but can't be bothered to implement it rn
        {:error, :not_found}
      end
    end
  end

  defp get_profile({:uuid, entity}) do
    Mojang.uuid_to_profile(entity)
  end

  defp get_profile({:username, entity}) do
    with {:ok, uuid} <- Mojang.username_to_uuid(entity) do
      get_profile({:uuid, uuid})
    end
  end
end
