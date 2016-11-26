defmodule Buckynix.Api.DeliveryController do
  use Buckynix.Web, :controller

  alias Buckynix.Delivery

  def index(conn, params) do
    try do
      current_organization = Map.fetch!(conn.assigns, :current_organization)

      filter = Map.get(params, "filter", %{})
      from = Map.get(filter, "from") |> Ecto.Date.cast!
      to = Map.get(filter, "to") |> Ecto.Date.cast!

      include = Map.get(params, "include", "")
      relationships = relationships(include)

      user_ids = get_user_ids(current_organization)

      deliveries = from(
        d in Delivery,
        preload: ^relationships,
        where: d.user_id in ^user_ids,
        where: fragment("date::date >= ? AND date::date <= ?", ^from, ^to) # XXX: strip the time for now
      )
      |> Repo.all

      render(conn, data: deliveries)
    rescue
      Ecto.CastError -> render(conn, "errors.json-api", data: %{title: "Missing filter dates"})
    end
  end

  defp relationships(include) do
    String.split(include, ",")
      |> MapSet.new
      |> MapSet.intersection(MapSet.new ~w(user))
      |> Enum.map(&String.to_atom/1)
  end

  defp get_user_ids(organization) do
    query = from u in Buckynix.User,
      join: ou in Buckynix.OrganizationUser, on: ou.user_id == u.id,
      where: ou.organization_id == ^organization.id,
      select: {u.id}

    query
      |> Buckynix.User.non_archived
      |> Repo.all
      |> Enum.map(fn(tuple) -> Tuple.to_list(tuple) |> List.first end)
  end
end
