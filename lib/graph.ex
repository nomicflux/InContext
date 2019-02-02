defmodule Graph do
  alias __MODULE__.Edge

  @moduledoc """
  Functional, Inductive Graph Implementation
  """

  defstruct in: %{}, out: %{}

  @doc """
  Hello world.

  ## Examples

      iex> InductiveGraph.hello()
      :world

  """
  def new do
    %Graph{}
  end

  @spec add_edge(%Graph{}, non_neg_integer, non_neg_integer, number) :: %Graph{}
  def add_edge(graph, from, to, weight \\ 1.0) do
    edge = Edge.new(from, to, weight)
    %{graph |
      in: Map.update(graph.in, to,
        MapSet.new([edge]),
        &MapSet.put(&1, edge)),
      out: Map.update(graph.out, from,
        MapSet.new([edge]),
        &MapSet.put(&1, edge))
    }
  end

  @spec empty?(%Graph{}) :: Boolean
  def empty?(graph), do: graph.in == %{} and graph.out == %{}

  @spec tree_graph(non_neg_integer) :: %Graph{}
  def tree_graph(n) do
    0..n |>
      Enum.reduce(Graph.new, fn (n, g) -> g |>
          Graph.add_edge(n, n * 2 + 1) |>
          Graph.add_edge(n, n * 2 + 2)
      end)
  end
end
