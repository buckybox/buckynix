defmodule Buckynix.Api.DeliveryController do
  use Buckynix.Web, :controller

  alias Buckynix.Delivery

  def index(conn, params) do
    try do
      filter = Map.get(params, "filter", %{})
      from = Map.get(filter, "from") |> Ecto.Date.cast!
      to = Map.get(filter, "to") |> Ecto.Date.cast!

      include = Map.get(params, "include", "")
      relationships = String.split(include, ",")
        |> MapSet.new
        |> MapSet.intersection(MapSet.new ["user"])
        |> Enum.map(&String.to_atom/1)

      deliveries = Repo.all(
        from d in Delivery,
        preload: ^relationships,
        where: fragment("date::date >= ? AND date::date <= ?", ^from, ^to) # XXX: strip the time for now
      )
      |> Enum.map(fn(delivery) -> delivery_with_formatted_date(delivery) end)

      render(conn, data: deliveries)
    rescue
      Ecto.CastError -> render(conn, "errors.json-api", data: %{title: "Missing filter dates"})
    end
  end

  defp delivery_with_formatted_date(delivery) do
    %{delivery |
      date: Ecto.DateTime.to_date(delivery.date)
     }
  end
end
