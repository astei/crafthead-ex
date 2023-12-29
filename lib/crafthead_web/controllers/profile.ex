defmodule CraftheadWeb.ProfileController do
  alias Crafthead.Util.Request
  alias CraftheadWeb.Util, as: WebUtil

  use CraftheadWeb, :controller

  action_fallback CraftheadWeb.FallbackController

  def show(conn, %{"entity" => entity}) do
    result =
      entity
      |> Request.what_entity()
      |> WebUtil.get_profile_for_entity()

    with {:ok, profile} <- result do
      conn
      |> put_status(:ok)
      |> put_resp_header("cache-control", "public, max-age=86400")
      |> json(profile)
    end
  end
end
