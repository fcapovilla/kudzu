defmodule KudzuWeb.Router do
  use KudzuWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Metatags.Plug,
      sitename:     "Kudzu",
      separator:    "|",
      default_tags: %{
        "title"       => "All the headlines in one place.",
        "description" => "Compare news headlines from different sources in one place.",
        "keywords"    => ["Kudzu News", "news aggregator", "compare headlines"]
      }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :admin do
    plug KudzuWeb.EnsureRolePlug, :admin
  end

  scope "/admin", KudzuWeb.Admin, as: :admin do
    pipe_through [:browser, :protected, :admin]

    resources "/users",  UserController
    resources "/feeds",  FeedController
    resources "/topics", TopicController
    resources "/tags",   TagController
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", KudzuWeb do
    pipe_through :browser

    get "/",      ArticleController, :index
    get "/about", PageController,    :index

    resources "/articles", ArticleController, only: [:index, :show] do
      post("/tag", ArticleController, :tag, as: :tag)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", KudzuWeb do
  #   pipe_through :api
  # end
end
