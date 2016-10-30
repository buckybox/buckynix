defmodule Buckynix.Money do
  def html(money) do
    class = if Money.negative?(money), do: " negative", else: ""

    Phoenix.HTML.raw ~s(<span class="money#{class}">#{money}</span>)
  end
end
