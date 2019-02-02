defmodule Graph.Edge do
  alias __MODULE__

  @enforce_keys [:from, :to]
  defstruct from: nil, to: nil, weight: 1.0

  def new(from, to, weight \\ 1.0), do: %Edge{from: from, to: to, weight: weight}
end
