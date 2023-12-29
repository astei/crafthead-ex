defmodule CraftheadWeb.Router do
  use CraftheadWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CraftheadWeb do
    pipe_through :api

    get "/profile/:entity", ProfileController, :show
    get "/skin/:entity", SkinController, :show

    ["avatar", "helm", "cube", "body", "bust", "cape"]
    |> Enum.each(fn render_type ->
      get "/#{render_type}/:entity", ImageController, String.to_atom(render_type)
      get "/#{render_type}/:entity/:size", ImageController, String.to_atom(render_type)
    end)

    ["body", "bust"]
    |> Enum.each(fn render_type ->
      get "/armor/#{render_type}/:entity",
          ImageController,
          String.to_atom("armor_" <> render_type)

      get "/armor/#{render_type}/:entity/:size",
          ImageController,
          String.to_atom("armor_" <> render_type)
    end)

    get "/ping", PingController, :show
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:crafthead, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: CraftheadWeb.Telemetry
    end
  end
end
