defmodule Buckynix.Coherence.Web do

  def view do
    quote do
      use Phoenix.View, root: "web/templates/coherence"
      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Buckynix.Router.Helpers
      import Buckynix.ErrorHelpers
      import Buckynix.Gettext
      import Buckynix.Coherence.ViewHelpers

    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
