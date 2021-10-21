defmodule Comp6000.Repo do
  use Ecto.Repo,
    otp_app: :comp6000,
    adapter: Ecto.Adapters.Postgres
end
