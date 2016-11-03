defmodule Buckynix.Router do
  use Buckynix.Web, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
    plug Buckynix.Plugs.Organization
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
    plug Buckynix.Plugs.Organization
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  scope "/" do
    pipe_through :browser
    coherence_routes
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", Buckynix do
    pipe_through :browser

    # Add public routes below
    get "/", PageController, :index
    get "/map", MapController, :index
  end

  scope "/", Buckynix do
    pipe_through :protected

    # Add protected routes below
    resources "/organizations", OrganizationController

    get "/customers/tag/:tag", CustomerController, :tag
    get "/customers/search", CustomerController, :search
    resources "/customers", CustomerController do
      resources "/orders", OrderController
    end
  end

  scope "/api", Buckynix do
    pipe_through :api

    resources "/customers", CustomerController, only: [:index] do
      resources "/transactions", TransactionController, only: [:index, :create]
    end
  end
end
