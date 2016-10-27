defmodule Buckynix.CustomerController do
  use Buckynix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, params) do
    render conn, "show.html", id: params["id"]
  end
end
