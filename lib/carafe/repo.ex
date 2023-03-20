defmodule Carafe.Repo do
  use Ecto.Repo,
    otp_app: :carafe,
    adapter: Ecto.Adapters.Postgres

  use Paginator
end
