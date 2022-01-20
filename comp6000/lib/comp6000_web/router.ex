defmodule Comp6000Web.Router do
  use Comp6000Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {Comp6000Web.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(Comp6000Web.Plugs.Session)
  end

  scope "/app", Comp6000Web do
    pipe_through(:browser)
    get("/*path", PageController, :index)
  end

  scope "/api", Comp6000Web do
    pipe_through(:api)

    scope "/users", User do
      get("/logout", UserController, :logout)
      get("/loggedin", UserController, :logged_in)
      get("/get-studies", UserController, :get_studies)

      post("/login", UserController, :login)
      post("/create", UserController, :create)
    end

    scope "/study", Study do
      post("/create", StudyController, :create)

      post("/:study_id/task/create", TaskController, :create)
      get("/:study_id/get_tasks", TaskController, :get_tasks)

      post("/:study_id/task/:task_id/answer/create", AnswerController, :create)

      post("/:study_id/background/:uuid/submit", ResultController, :background_submit)
      post("/:study_id/task/:task_id/:uuid/result/submit", ResultController, :result_submit)

      post(
        "/:study_id/task/:task_id/:uuid/replay_data/append",
        ResultController,
        :append_replay_data
      )

      get(
        "/:study_id/task/:task_id/:uuid/replay_data/complete",
        ResultController,
        :complete_replay_data
      )
    end

    get("/*path", PageController, :error)
    post("/*path", PageController, :error)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: Comp6000Web.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
