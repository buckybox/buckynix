defmodule Buckynix.Api.UserController do
  use Buckynix.Web, :controller

  alias Buckynix.User

  def index(conn, params) do
    current_organization = Map.fetch!(conn.assigns, :current_organization)
    count = Map.get(params, "count")
    filter = Map.get(params, "filter", "")

    all_users = get_users(current_organization)
    users = get_users(current_organization, filter)

    total_count = Repo.aggregate(all_users, :count, :id)
    filter_count = Repo.aggregate(users, :count, :id)

    users = case count do
      nil -> users
      count -> users |> limit(^count)
    end

    users = users |> Repo.all

    meta = %{
      "filter-count" => filter_count,
      "total-count" => total_count
    }

    render(conn, :index, data: users, opts: [meta: meta])
  end

  defp get_users(organization, filter \\ "") do
    tag_regex = ~r/tag:(\w+)/
    tag = List.last(Regex.run(tag_regex, filter) || [])
    filter = String.strip Regex.replace(tag_regex, filter, "") # remove tag from filter

    query = from u in User,
      join: ou in Buckynix.OrganizationUser, on: ou.user_id == u.id,
      where: ou.organization_id == ^organization.id,
      preload: [:account],
      where: ilike(u.name, ^"%#{filter}%")

    query |> User.with_tag(tag) |> User.non_archived
  end
end
