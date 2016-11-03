defmodule Buckynix.Plugs.Organization do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    current_organization = if String.starts_with?(conn.request_path, "/customers") do # FIXME
      get_session(conn, :current_organization)
    else
      nil
    end

    assign(conn, :current_organization, current_organization)
  end
end
