defmodule Buckynix.Api.UserController do
  use Buckynix.Web, :controller

  alias Buckynix.User

  def index(conn, params) do
    count = Map.get(params, "count")
    filter = Map.get(params, "filter", "")

    users = get_users(filter)

    filter_count = Repo.aggregate(users, :count, :id)
    total_count = Repo.aggregate(User, :count, :id)

    users = case count do
      nil -> users
      count -> users |> limit(^count)
    end

    users =
      users
      |> Repo.all

    meta = %{
      "filter-count" => filter_count,
      "total-count" => total_count
    }

    render(conn, :index, data: users, opts: [meta: meta])
  end

  defp get_users(filter) do
    tag_regex = ~r/tag:(\w+)/
    tag = List.last(Regex.run(tag_regex, filter) || [])
    filter = String.strip Regex.replace(tag_regex, filter, "") # remove tag from filter

    query = from u in User,
      preload: [:account],
      where: ilike(u.name, ^"%#{filter}%")

    query |> User.with_tag(tag) |> User.non_archived
  end
end
