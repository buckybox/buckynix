defmodule Buckynix.Plugs.Organization do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    current_organization = if conn.request_path =~ ~r/\A(\/|\/organizations)\z/ do # FIXME
      nil
    else
      get_session(conn, :current_organization)
    end

    assign(conn, :current_organization, current_organization)
  end
end
