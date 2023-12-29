defmodule CraftheadWeb.SkinController do
  alias Crafthead.Clients.Mojang
  alias Crafthead.Profile.Minecraft
  alias Crafthead.Util.Request
  alias Crafthead.Util.Skin

  alias CraftheadWeb.Util, as: WebUtil

  use CraftheadWeb, :controller

  action_fallback CraftheadWeb.FallbackControlle

  def show(conn, %{"entity" => raw_entity}) do
    entity = raw_entity |> Request.what_entity()

    with {:ok, profile} <- WebUtil.get_profile_from_entity(entity),
         texture_info <- Minecraft.get_skin_info(profile) do
      if texture_info.skin do
        with {:ok, skin} <- Mojang.fetch_skin_from_texture_url(texture_info.skin.url) do
          conn
          |> put_resp_header("cache-control", "public, max-age=86400")
          |> put_resp_header("content-type", "image/png")
          |> send_resp(200, skin)
        end
      else
        # show a fallback
        fallback_skin =
          profile.id
          |> Skin.fallback_skin_type()
          |> Skin.load_default_skin()

        conn
        |> put_resp_header("content-type", "image/png")
        |> put_resp_header("x-crafthead-profile", "miss")
        |> send_resp(404, fallback_skin)
      end
    end
  end
end
