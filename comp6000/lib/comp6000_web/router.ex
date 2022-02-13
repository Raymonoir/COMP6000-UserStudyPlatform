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
      post("/login", UserController, :login)
      post("/create", UserController, :create)
      post("/edit", UserController, :edit)
      post("/delete", UserController, :delete)
      # get("/get-studies", UserController, :get_studies)
    end

    scope "/study", Study do
      post("/create", StudyController, :create)
      post("/edit", StudyController, :edit)
      post("/delete", StudyController, :delete)
      post("/get", StudyController, :get)
    end

    scope "/task" do
      post("/create", TaskController, :create)
      post("/edit", TaskController, :edit)
      post("/delete", TaskController, :delete)
      post("/get", TaskController, :get)
    end

    scope "/answer" do
      post("/get", AnswerController, :get)
      post("/create", AnswerController, :create)
      post("/edit", AnswerController, :edit)
      post("/delete", AnswerController, :delete)
    end

    scope "/data" do
      post("/append", ResultController, :append_data)
      post("/complete", ResultController, :complete_data)
      post("/get", ResultController, :get)
    end

    scope "/participant", Participant do
      get("/get-uuid", ParticipantController, :get_participant_uuid)
      get("/:participant_uuid/list-results", ParticipantController, :get_participant_results)
    end

    # TODO
    scope "/metrics", Metrics do
      get("/:task_id", MetricsController, :get_metrics_for_task)
      get("/:task_id/:participant_uuid", MetricsController, :get_metrics_for_result)
      get("/:particpant_uuid", MetricsController, :get_metrics_for_participant)
    end

    # post("/:study_id/background/:uuid/submit", ResultController, :background_submit)
    # post("/:study_id/task/:task_id/:uuid/result/submit", ResultController, :result_submit)
    # get("/:study_id/task/:task_id/get-results", ResultController, :get_results)

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
