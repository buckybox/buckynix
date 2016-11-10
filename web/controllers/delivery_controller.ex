defmodule Buckynix.DeliveryController do
  use Buckynix.Web, :controller

  alias Buckynix.Delivery

  def index(conn, _params) do
    deliveries = Repo.all(Delivery)
    render(conn, "index.html", deliveries: deliveries)
  end
end
