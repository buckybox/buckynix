defmodule Buckynix.SessionController do
  use Buckynix.Web, :controller

  alias Buckynix.User

  def create(conn, %{"data" => %{"attributes" => credentials}}) do
    email = Map.get(credentials, "email")
    password = Map.get(credentials, "password")
    changeset = User.changeset(%User{}, %{email: email})

    case Repo.update(changeset) do
      {:ok, session} ->
        conn
        |> put_status(:created)
        |> render("show.json", session: session)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Buckynix.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    session = Repo.get!(Session, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(session)

    send_resp(conn, :no_content, "")
  end
end
