defmodule InContext.Graph do
  alias __MODULE__
  alias __MODULE__.Edge

  @moduledoc """
  Functional, Inductive Graph Implementation
  """

  @type node_id :: term

  @opaque t :: %Graph{
    in: %{ node_id => MapSet.t(Edge.t) },
    out: %{ node_id => MapSet.t(Edge.t) }
  }

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
  @spec in_edges(Graph.t(), node_id) :: MapSet.t()
  def in_edges(graph, node) do
    Map.get(graph.in, node, MapSet.new())
  end

  @doc """
  Retrieve the edges leaving a node.
  """
  @spec out_edges(Graph.t(), node_id) :: MapSet.t()
  def out_edges(graph, node) do
    Map.get(graph.out, node, MapSet.new())
  end

  @doc """
  Add an edge to a graph.

  ## Examples

      iex> use InContext
      iex> graph = Graph.new |> Graph.add_edge(1,2)
      iex> Graph.in_edges(graph, 2) |> MapSet.to_list |> Enum.map(&Edge.from/1)
      [1]
      iex> Graph.out_edges(graph, 1) |> MapSet.to_list |> Enum.map(&Edge.to/1)
      [2]
  """
  @spec add_edge(Graph.t(), node_id, node_id, number) :: Graph.t()
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
  @spec has_node?(Graph.t(), node_id) :: Boolean
  def has_node?(graph, node), do: Map.has_key?(graph.in, node) or Map.has_key?(graph.out, node)

  @doc """
  Use an existing graph as a basis for new edges.

  ## Example

      iex> use InContext
      iex> {graph1, _} = 1 ~> 2
      iex> {graph2, _} = graph1 ~>> 3 ~> 4 ~> 2
      iex> Graph.in_edges(graph2, 2) |> MapSet.to_list |> Enum.map(&Edge.from/1)
      [1, 4]
  """
  def (%Graph{}=g) ~>> node, do: {g, node}

  @doc """
  Create a graph by stringing together nodes going from left to right.

  Returns tuple of graph and last node added, to thread nodes together into a graph.

  ## Example

      iex> use InContext
      iex> {graph, _} = 1 ~> 2 ~> 3
      iex> Graph.in_edges(graph, 2) |> MapSet.to_list |> Enum.map(&Edge.from/1)
      [1]
      iex> Graph.out_edges(graph, 2) |> MapSet.to_list |> Enum.map(&Edge.to/1)
      [3]
  """
  def {g, node1} ~> {node2, weight}, do: {g |> add_edge(node1, node2, weight), node2}
  def {g, node1} ~> node2, do: {g |> add_edge(node1, node2), node2}
  def node1 ~> {node2, weight}, do: {new() |> add_edge(node1, node2, weight), node2}
  def node1 ~> node2, do: {new() |> add_edge(node1, node2), node2}

  @doc """
  Create a graph by stringing together nodes going from right to left.

  Returns tuple of graph and last node added, to thread nodes together into a graph.

  ## Example

      iex> use InContext
      iex> {graph, _} = 1 <~ 2 <~ 3
      iex> Graph.in_edges(graph, 2) |> MapSet.to_list |> Enum.map(&Edge.from/1)
      [3]
      iex> Graph.out_edges(graph, 2) |> MapSet.to_list |> Enum.map(&Edge.to/1)
      [1]
  """
  def {g, node1} <~ {node2, weight}, do: {g |> add_edge(node2, node1, weight), node2}
  def {g, node1} <~ node2, do: {g |> add_edge(node2, node1), node2}
  def node1 <~ {node2, weight}, do: {new() |> add_edge(node2, node1, weight), node2}
  def node1 <~ node2, do: {new() |> add_edge(node2, node1), node2}

  @doc """
  Create a graph by stringing together nodes going from right to left and back.

  Returns tuple of graph and last node added, to thread nodes together into a graph.

  ## Example

      iex> use InContext
      iex> {graph, _} = 1 <~> 2 <~> 3
      iex> Graph.in_edges(graph, 2) |> MapSet.to_list |> Enum.map(&Edge.from/1)
      [1, 3]
      iex> Graph.out_edges(graph, 2) |> MapSet.to_list |> Enum.map(&Edge.to/1)
      [1, 3]
  """
  def {g, node1} <~> {node2, weight}, do: {g |> add_edge(node1, node2, weight) |> add_edge(node2, node1, weight), node2}
  def {g, node1} <~> node2, do: {g |> add_edge(node1, node2) |> add_edge(node2, node1), node2}
  def node1 <~> {node2, weight}, do: {new() |> add_edge(node1, node2, weight) |> add_edge(node2, node1, weight), node2}
  def node1 <~> node2, do: {new() |> add_edge(node1, node2) |> add_edge(node2, node1), node2}
end
