defmodule Buckynix.PageController do
  use Buckynix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
