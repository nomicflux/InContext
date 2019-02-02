defmodule InContext.Graph.Edge do
  alias __MODULE__

  @moduledoc """
  Weighted, Directed Graph Edges
  """

  @enforce_keys [:from, :to]
  defstruct from: nil, to: nil, weight: 1.0

  @doc """
  Returns new edge from `from` to `to`, with optional `weight`.
  """
  def new(from, to, weight \\ 1.0), do: %Edge{from: from, to: to, weight: weight}

  @doc """
  Retrieve `from` node from given `Edge`.
  """
  def from(%Edge{from: from}), do: from

  @doc """
  Retrieve `to` node from given `Edge`.
  """
  def to(%Edge{to: to}), do: to

  @doc """
  Retrieve `weight` from given `Edge`.
  """
  def weight(%Edge{weight: weight}), do: weight

  @doc """
  Returns edge as a triple, for implementation-independent representations.
  """
  def as_triple(%Edge{from: from, to: to, weight: weight}), do: {from, to, weight}

  @doc """
  Returns edge as a pair without weight, for implementation-independent representations.
  """
  def as_pair(%Edge{from: from, to: to}), do: {from, to}
end
