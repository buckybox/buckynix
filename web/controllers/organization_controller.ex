defmodule Buckynix.OrganizationController do
  use Buckynix.Web, :controller

  alias Buckynix.Organization

  def index(conn, _params) do
    user = conn.assigns[:current_user]
    organizations = Repo.all(assoc(user, :organizations))
    render(conn, "index.html", organizations: organizations)
  end

  def new(conn, _params) do
    changeset = Organization.changeset(%Organization{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"organization" => organization_params}) do
    changeset = Organization.changeset(%Organization{}, organization_params)

    case Repo.insert(changeset) do
      {:ok, _organization} ->
        conn
        |> put_flash(:info, "Organization created successfully.")
        |> redirect(to: organization_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)

    conn
    |> put_session(:current_organization, organization.id)
    |> redirect(to: user_path(conn, :index))
  end

  def edit(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)
    changeset = Organization.changeset(organization)
    render(conn, "edit.html", organization: organization, changeset: changeset)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    organization = Repo.get!(Organization, id)
    changeset = Organization.changeset(organization, organization_params)

    case Repo.update(changeset) do
      {:ok, organization} ->
        conn
        |> put_flash(:info, "Organization updated successfully.")
        |> redirect(to: organization_path(conn, :show, organization))
      {:error, changeset} ->
        render(conn, "edit.html", organization: organization, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(organization)

    conn
    |> put_flash(:info, "Organization deleted successfully.")
    |> redirect(to: organization_path(conn, :index))
  end
end
