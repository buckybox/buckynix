defmodule Buckynix.Api.DeliveryController do
  use Buckynix.Web, :controller

  alias Buckynix.Delivery

  def index(conn, params) do
    from = get_window params, "from"
    to = get_window params, "to"
    # only_count = Map.get(params, "only-count", false)

    deliveries = Repo.all(
      from d in Delivery,
      preload: [:user],
      where: fragment("date::date >= ? AND date::date <= ?", ^from, ^to) # XXX: strip the time for now
    )
    |> Enum.map(fn(delivery) -> delivery_with_formatted_date(delivery) end)

    render(conn, data: deliveries)
  end

  defp get_window(params, bound) do
    Map.get(params, "filter[#{bound}]", Timex.today)
      |> Ecto.Date.cast!
  end

  defp delivery_with_formatted_date(delivery) do
    %{delivery |
      date: Ecto.DateTime.to_date(delivery.date)
     }
  end
end
