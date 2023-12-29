defmodule CraftheadWeb.ProfileController do
  alias Crafthead.Clients.Mojang
  alias Crafthead.Util.Request

  use CraftheadWeb, :controller

  action_fallback CraftheadWeb.FallbackController

  def show(conn, %{"entity" => entity}) do
    result =
      entity
      |> Request.what_entity()
      |> get_profile()

    with {:ok, profile} <- result do
      conn
      |> put_status(:ok)
      |> put_resp_header("cache-control", "public, max-age=86400")
      |> json(profile)
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
