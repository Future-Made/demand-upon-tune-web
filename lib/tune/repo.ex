defmodule Tune.Repo do
  use Ecto.Repo,
    otp_app: :tune,
    adapter: Ecto.Adapters.Postgres
end
