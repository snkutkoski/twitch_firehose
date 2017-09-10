defmodule TwitchFirehoseWeb.PageControllerTest do
  use TwitchFirehoseWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Twitch Firehose Demo"
  end
end
