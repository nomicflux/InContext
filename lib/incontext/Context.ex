defmodule InContext.Context do
  alias __MODULE__
  alias InContext.Graph
  alias InContext.Graph.Edge

  @moduledoc """
  Contextual Views on Graphs

  @todo (longterm): Write map and reduce functions
  """
  @type node_id :: term
  @type edge_triple :: {node_id, node_id, number}

  @opaque t :: %Context{
    in_edges: MapSet.t(Edge.t()),
    node: node_id,
    out_edges: MapSet.t(Edge.t())
  }

  @enforce_keys [:node]
  defstruct in_edges: MapSet.new, node: nil, out_edges: MapSet.new

  @doc """
  Creates a view from a graph at a given node, and returns the rest of the graph

  ## Examples

      iex> use InContext
      iex> graph = Graph.new |>
      ...>   Graph.add_edge(1,2) |>
      ...>   Graph.add_edge(2,3) |>
      ...>   Graph.add_edge(1,3)
      iex> {ctx, graph2} = Context.view(graph, 2)
      iex> ctx.node
      2
      iex> Context.edge_list(ctx)
      { [{1, 2, 1.0}], [{2, 3, 1.0}] }
      iex> Graph.has_node?(graph, 2)
      :true
      iex> Graph.has_node?(graph2, 2)
      :false
  """
  @spec view(Graph.t(), node_id | nil) :: {Context.t(), Graph.t()} | nil
  def view(_, nil), do: nil
  def view(graph, node) do
    if Graph.has_node?(graph, node) do
      {ins, ins_next} = partition_map(graph.in, node)
      {outs, outs_next} = partition_map(graph.out, node)
      {%Context{in_edges: ins,
                node: node,
                out_edges: outs},
       %Graph{in: ins_next,
              out: outs_next}}
    else
      nil
    end
  end

  @doc """
  Returns implementation-indpendent view of edges in a context.
  """
  @spec edge_list(Context.t()) :: { [edge_triple], [edge_triple]}
  def edge_list(ctx) do
    { ctx.in_edges |> MapSet.to_list |> Enum.map(&Edge.as_triple/1),
      ctx.out_edges |> MapSet.to_list |> Enum.map(&Edge.as_triple/1) }
  end

  defp partition_map(map, node) do
    case Map.fetch(map, node) do
      {:ok, result} -> { result, Map.delete(map, node) }
      :error -> { MapSet.new, map }
    end
  end
end
