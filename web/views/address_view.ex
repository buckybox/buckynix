defmodule Buckynix.AddressView do
  use Buckynix.Web, :view

  defimpl Phoenix.HTML.Safe, for: Buckynix.Address do
    def to_iodata(address) do
      parts = Enum.filter [
        address.street,
        address.state,
        address.zip,
        address.city
      ], (fn(part) -> part && part != "" end)

      Enum.join parts, "<br>"
    end
  end
end
