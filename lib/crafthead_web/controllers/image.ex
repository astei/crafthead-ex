defmodule CraftheadWeb.ImageController do
  alias Crafthead.Clients.Mojang
  alias Crafthead.Profile.Minecraft
  alias Crafthead.Renderer
  alias Crafthead.Util.Request

  use CraftheadWeb, :controller

  action_fallback CraftheadWeb.FallbackController

  defp try_render(skin, options) do
    case Renderer.render_image(skin, options) do
      {error, _} -> {:error, error}
      render -> {:ok, render}
    end
  end

  def avatar(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    size = Map.get(params, "size", "128") |> String.to_integer()
    image(conn, entity, %Crafthead.Renderer.RenderOptions{size: size, render_type: :avatar})
  end

  def helm(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    size = Map.get(params, "size", "128") |> String.to_integer()
    image(conn, entity, %Crafthead.Renderer.RenderOptions{size: size, render_type: :helm})
  end

  def cube(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    size = Map.get(params, "size", "128") |> String.to_integer()
    image(conn, entity, %Crafthead.Renderer.RenderOptions{size: size, render_type: :cube})
  end

  def body(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    size = Map.get(params, "size", "128") |> String.to_integer()
    image(conn, entity, %Crafthead.Renderer.RenderOptions{size: size, render_type: :body})
  end

  def bust(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    size = Map.get(params, "size", "128") |> String.to_integer()
    image(conn, entity, %Crafthead.Renderer.RenderOptions{size: size, render_type: :bust})
  end

  def cape(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    size = Map.get(params, "size", "128") |> String.to_integer()
    image(conn, entity, %Crafthead.Renderer.RenderOptions{size: size, render_type: :cape}, :cape)
  end

  defp image(conn, entity, render_options, texture \\ :skin) do
    with {:ok, profile} <- get_profile(entity),
         texture_info <- Minecraft.get_skin_info(profile) do
      if Map.get(texture_info, texture) do
        adjusted_options = render_options
        |> Map.merge(%{model: render_options.model || texture_info.skin.model})
        |> Crafthead.Renderer.RenderOptions.new()

        with {:ok, skin_raw} <- Mojang.fetch_skin_from_texture_url(Map.get(texture_info, texture).url),
              {:ok, render} <- try_render(skin_raw, adjusted_options) do
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
