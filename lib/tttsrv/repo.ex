defmodule Tttsrv.Repo do
  use Ecto.Repo,
    otp_app: :tttsrv,
    adapter: Ecto.Adapters.Postgres
end
