defmodule TwitchFirehoseWeb.PageController do
  use TwitchFirehoseWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
