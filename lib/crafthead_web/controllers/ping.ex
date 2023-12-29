defmodule CraftheadWeb.PingController do
  use CraftheadWeb, :controller

  def show(conn, _) do
    json(conn, %{pong: true})
  end
end
