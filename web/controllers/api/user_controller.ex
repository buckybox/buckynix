defmodule Buckynix.Api.UserController do
  use Buckynix.Web, :controller

  alias Buckynix.User

  def index(conn, params) do
    count = Map.get(params, "count", 0)
    filter = Map.get(params, "filter", "")

    users = get_users(filter)
    users =
      users
      |> limit(^count)
      |> Repo.all
      |> Enum.map(fn(user) -> user_with_url_and_balance(conn, user) end)

    filter_count = Repo.aggregate(get_users(filter), :count, :id)
    total_count = Repo.aggregate(User, :count, :id)

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

    query = from c in User,
      preload: [:account],
      where: ilike(c.name, ^"%#{filter}%")

    query |> User.with_tag(tag) |> User.non_archived
  end

  defp user_with_url_and_balance(conn, user) do # TODO: move to view?
    %{user |
      url: user_path(conn, :show, user),
      balance: (Phoenix.HTML.safe_to_string Buckynix.Money.html(user.account.balance))
     }
  end
end
