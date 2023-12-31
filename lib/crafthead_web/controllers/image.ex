defmodule CraftheadWeb.ImageController do
  @always_renders_steve_uuid "fffffff0fffffff0fffffff0fffffff0"

  @min_image_size 8
  @max_image_size 300

  alias Crafthead.Clients.Mojang
  alias Crafthead.Profile.Minecraft
  alias Crafthead.Renderer
  alias Crafthead.Util.Request
  alias Crafthead.Util.Skin

  alias CraftheadWeb.Util, as: WebUtil

  alias Plug.Conn

  use CraftheadWeb, :controller

  action_fallback CraftheadWeb.FallbackController

  defp try_render(skin, options) do
    case Renderer.render_image(skin, options) do
      {:error, error} -> {:error, error}
      render -> {:ok, render}
    end
  end

  defp maybe_get_skin_model_override(model) do
    case model do
      "slim" -> :slim
      "default" -> :classic
      "classic" -> :classic
      _ -> nil
    end
  end

  def get_render_options(render_type, params, options \\ []) do
    armored = Keyword.get(options, :armored, false)

    raw_size = Map.get(params, "size", "128") |> String.to_integer()
    # clamp the size to reasonable values to prevent resource exhaustion
    size = Request.clamp(@min_image_size, raw_size, @max_image_size)

    %Crafthead.Renderer.RenderOptions{
      size: size,
      render_type: render_type,
      model: Map.get(params, "model") |> maybe_get_skin_model_override(),
      armored: armored
    }
  end

  def avatar(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:avatar, params))
  end

  def helm(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:helm, params))
  end

  def cube(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:cube, params))
  end

  def body(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:body, params))
  end

  def bust(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:bust, params))
  end

  def armor_body(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:body, params, armored: true))
  end

  def armor_bust(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:bust, params, armored: true))
  end

  def cape(conn, %{"entity" => raw_entity} = params) do
    entity = raw_entity |> Request.what_entity()
    image(conn, entity, get_render_options(:cape, params), :cape)
  end

  defp image(conn, entity, render_options, texture \\ :skin) do
    with {:ok, profile} <- WebUtil.get_potentially_fake_profile_from_entity(entity),
         texture_info <- Minecraft.get_skin_info(profile) do
      conn |> Conn.fetch_query_params()

      if Map.get(texture_info, texture) do
        adjusted_options =
          render_options
          |> Map.merge(%{model: render_options.model || texture_info.skin.model})

        with {:ok, skin_raw} <-
               Mojang.fetch_skin_from_texture_url(Map.get(texture_info, texture).url),
             {:ok, render} <- try_render(skin_raw, adjusted_options) do
          conn
          |> put_resp_header("cache-control", "public, max-age=86400")
          |> put_resp_header("content-type", "image/png")
          |> send_resp(200, render)
        end
      else
        # render the fallback
        fallback_skin = profile.id |> Skin.fallback_skin_type()

        model =
          render_options.model ||
            case fallback_skin do
              :alex -> :slim
              :steve -> :classic
            end

        skin_raw = Skin.load_default_skin(fallback_skin)
        adjusted_options = render_options |> Map.merge(%{model: model})

        status =
          case profile.id do
            @always_renders_steve_uuid -> 200
            _ -> 404
          end

        with {:ok, render} <- try_render(skin_raw, adjusted_options) do
          conn
          |> put_resp_header("content-type", "image/png")
          |> put_resp_header("x-crafthead-profile", "miss")
          |> put_resp_header("x-crafthead-fallback", to_string(fallback_skin))
          |> send_resp(status, render)
        end
      end
    end
  end
end
