defmodule Buckynix.Plugs.Assigns do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    current_organization = if conn.request_path =~ ~r/\A(\/|\/organizations)\z/ do # FIXME
      nil
    else
      Map.get(conn.assigns, :current_organization, # use existing assign for tests
              get_session(conn, :current_organization))
    end

    current_user = Coherence.current_user(conn)

    conn
    |> assign(:current_organization, current_organization)
    |> assign(:current_user, current_user)
  end
end
