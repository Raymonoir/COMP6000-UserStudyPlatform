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

      post("/:username/edit", UserController, :edit)
      get("/:username/delete", UserController, :delete)
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

    scope "/study", Study do
      post("/create", StudyController, :create)
      post("/:study_id/edit", StudyController, :edit)
      get("/:study_id/delete", StudyController, :delete)
      get("/:study_id/get-all", StudyController, :get_all)

      post("/:study_id/task/create", TaskController, :create)
      post("/:study_id/task/:task_id/edit", TaskController, :edit)
      get("/:study_id/task/:task_id/delete", TaskController, :delete)

      get("/:study_id/get_tasks", TaskController, :get_tasks)
      get("/get-by/id/:id", StudyController, :get_study_by_id)
      get("/get-by/participant-code/:participant_code", StudyController, :get_study_by_code)

      post("/:study_id/task/create", TaskController, :create)
      get("/:study_id/get-tasks", TaskController, :get_tasks)

      post("/:study_id/task/:task_id/answer/create", AnswerController, :create)
      post("/:study_id/task/:task_id/answer/edit", AnswerController, :edit)
      get("/:study_id/task/:task_id/answer/delete", AnswerController, :delete)

      post("/:study_id/background/:uuid/submit", ResultController, :background_submit)
      post("/:study_id/task/:task_id/:uuid/result/submit", ResultController, :result_submit)
      get("/:study_id/task/:task_id/get-results", ResultController, :get_results)

      # Where :datatype is either "compile-data" or "replay-data"
      post(
        "/:study_id/task/:task_id/:uuid/:data_type/append",
        ResultController,
        :append_data
      )

      get(
        "/:study_id/task/:task_id/:uuid/:data_type/complete",
        ResultController,
        :complete_data
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
