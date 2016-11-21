defmodule Buckynix.Api.SessionView do
  use Buckynix.Web, :view

  def render("show.json", %{session: session}) do
    %{data: render_one(session, Buckynix.SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{id: session.id,
      user_id: session.user_id}
  end
end
