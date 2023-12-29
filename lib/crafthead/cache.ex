defmodule Crafthead.Cache do
  use Nebulex.Cache,
    otp_app: :crafthead,
    adapter: Nebulex.Adapters.Local
end
