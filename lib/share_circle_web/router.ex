defmodule ShareCircleWeb.Router do
  use ShareCircleWeb, :router

  import ShareCircleWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShareCircleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :accepts_json do
    plug :accepts, ["html", "json"]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ShareCircleWeb.Plugs.AuthenticateApi
    plug ShareCircleWeb.Plugs.RateLimit, bucket: :read
  end

  pipeline :api_write do
    plug ShareCircleWeb.Plugs.RateLimit, bucket: :write
  end

  pipeline :api_family do
    plug ShareCircleWeb.Plugs.LoadCurrentFamily
  end

  scope "/", ShareCircleWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # OpenAPI spec and Swagger UI — no auth required
  scope "/api/v1" do
    pipe_through [:accepts_json]

    get "/openapi.json", OpenApiSpex.Plug.RenderSpec, []
    get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/api/v1/openapi.json"
  end

  scope "/api/v1", ShareCircleWeb.Api.V1 do
    pipe_through :api

    # Single-resource routes — no family_id in URL, membership checked in context
    resources "/posts", PostController, only: [:show, :update, :delete] do
      resources "/comments", CommentController, only: [:index, :create]
      put "/reactions/:emoji", ReactionController, :upsert
      delete "/reactions/:emoji", ReactionController, :delete
    end

    resources "/comments", CommentController, only: [:update, :delete] do
      put "/reactions/:emoji", ReactionController, :upsert
      delete "/reactions/:emoji", ReactionController, :delete
    end

    scope "/families/:family_id" do
      pipe_through [:api_family, :api_write]

      resources "/posts", PostController, only: [:index, :create]

      scope "/posts/:post_id" do
        resources "/comments", CommentController, only: [:create]
      end
    end
  end

  # Feed LiveView — requires authenticated browser session with family context
  scope "/", ShareCircleWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/feed", FeedLive, :index
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:share_circle, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShareCircleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ShareCircleWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
  end

  scope "/", ShareCircleWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email
  end

  scope "/", ShareCircleWeb do
    pipe_through [:browser]

    get "/users/log-in", UserSessionController, :new
    get "/users/log-in/:token", UserSessionController, :confirm
    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
