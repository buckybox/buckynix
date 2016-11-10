defmodule Buckynix.DeliveryController do
  use Buckynix.Web, :controller

  alias Buckynix.Delivery

  def index(conn, _params) do
    render(conn, :index)
  end
end
