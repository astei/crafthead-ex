defmodule CraftheadWeb.AvatarController do
  alias Crafthead.Clients.Mojang
  alias Crafthead.Profile.Minecraft
  alias Crafthead.Renderer
  alias Crafthead.Util.Request

  use CraftheadWeb, :controller

  action_fallback CraftheadWeb.FallbackControlle

  defp try_render(skin, options) do
    case Renderer.render_image(skin, options) do
      {error, _} -> {:error, error}
      render -> {:ok, render}
    end
  end

  def show(conn, %{"entity" => raw_entity}) do
    entity = raw_entity |> Request.what_entity()

    with {:ok, profile} <- get_profile(entity),
         texture_info <- Minecraft.get_skin_info(profile) do
      if Map.has_key?(texture_info, :skin) do
        model = texture_info.skin.model

        options = %Crafthead.Renderer.RenderOptions{
          model: model,
          size: 300,
          armored: false,
          render_type: :cube
        }

        with {:ok, skin_raw} <- Mojang.fetch_skin_from_texture_url(texture_info.skin.url),
             {:ok, render} <- try_render(skin_raw, options) do
          conn
          |> put_resp_header("cache-control", "public, max-age=86400")
          |> put_resp_header("content-type", "image/png")
          |> send_resp(200, render)
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
