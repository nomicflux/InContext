defmodule InContext.Graph do
  alias __MODULE__
  alias __MODULE__.Edge

  @moduledoc """
  Functional, Inductive Graph Implementation

  @todo: Create Node module for labelled nodes
  """

  defstruct in: %{}, out: %{}

  @doc """
  Create a new graph.

  ## Examples

      iex> use InContext
      iex> graph = Graph.new
      iex> Graph.empty?(graph)
      :true

  """
  @spec new :: %Graph{}
  def new do
    %Graph{}
  end

  @doc """
  Retrieve the edges going in to a node.
  """
  @spec in_edges(Graph.t(), node) :: MapSet.t()
  def in_edges(graph, node) do
    Map.get(graph.in, node, MapSet.new())
  end

  @doc """
  Retrieve the edges leaving a node.
  """
  @spec out_edges(Graph.t(), node) :: MapSet.t()
  def out_edges(graph, node) do
    Map.get(graph.out, node, MapSet.new())
  end

  @doc """
  Add an edge to a graph.

  ## Examples

      iex> use InContext
      iex> graph = Graph.new |> Graph.add_edge(1,2)
      iex> Graph.in_edges(graph, 2)
      #MapSet<[%InContext.Graph.Edge{from: 1, to: 2, weight: 1.0}]>
      iex> Graph.out_edges(graph, 1)
      #MapSet<[%InContext.Graph.Edge{from: 1, to: 2, weight: 1.0}]>
  """
  @spec add_edge(Graph.t(), node, node, number) :: Graph.t()
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

  @doc """
  Returns whether a graph is empty.

  ## Examples

      iex> use InContext
      iex> Graph.new |> Graph.empty?()
      :true

      iex> use InContext
      iex> Graph.new |> Graph.add_edge(1,2) |> Graph.empty?()
      :false
  """
  @spec empty?(Graph.t()) :: Boolean
  def empty?(graph), do: graph.in == %{} and graph.out == %{}

  @doc """
  Create a tree with nodes from 0 to `n` * 2 + 2.
  """
  @spec tree_graph(non_neg_integer) :: %Graph{}
  def tree_graph(n) do
    0..n |>
      Enum.reduce(Graph.new, fn (n, g) -> g |>
          Graph.add_edge(n, n * 2 + 1) |>
          Graph.add_edge(n, n * 2 + 2)
      end)
  end

  @doc """
  Return whether a graph has a given node.
  """
  def has_node?(graph, node), do: Map.has_key?(graph.in, node) or Map.has_key?(graph.out, node)
end
