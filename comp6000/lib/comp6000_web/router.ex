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
      get("/get", UserController, :get)
    end

    scope "/study", Study do
      post("/create", StudyController, :create)
      post("/edit", StudyController, :edit)
      post("/delete", StudyController, :delete)
      post("/get", StudyController, :get)
    end

    scope "/task", Task do
      post("/create", TaskController, :create)
      post("/edit", TaskController, :edit)
      post("/delete", TaskController, :delete)
      post("/get", TaskController, :get)
    end

    scope "/answer", Answer do
      post("/get", AnswerController, :get)
      post("/create", AnswerController, :create)
      post("/edit", AnswerController, :edit)
      post("/delete", AnswerController, :delete)
    end

    scope "/data", Metrics do
      post("/append", MetricsController, :append_data)
      post("/complete", MetricsController, :complete_data)
      post("/get", MetricsController, :get)
    end

    scope "/metrics", Metrics do
      post("/particpant", MetricsController, :get_metrics_for_participant)
      post("/study", MetricsController, :get_metrics_for_study)
    end

    scope "/survey", Survey do
      post("/pre/create", SurveyController, :create_pre)
      post("/pre/get", SurveyController, :get_pre)
      post("/pre/submit", SurveyController, :submit_pre)

      post("/post/create", SurveyController, :create_post)
      post("/post/get", SurveyController, :get_post)
      post("/post/submit", SurveyController, :submit_post)
    end

    scope "/participant", Participant do
      get("/get-uuid", ParticipantController, :get_participant_uuid)
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
