defmodule InContext.Context do
  alias __MODULE__
  alias InContext.Graph
  alias InContext.Graph.Edge

  @moduledoc """
  Contextual Views on Graphs
  """

  @enforce_keys [:node]
  defstruct in_edges: MapSet.new, node: nil, out_edges: MapSet.new

  @doc """
  Creates a view from a graph at a given node, and returns the rest of the graph

  ## Examples

      iex> graph = InContext.Graph.new |>
      ...>   InContext.Graph.add_edge(1,2) |>
      ...>   InContext.Graph.add_edge(2,3) |>
      ...>   InContext.Graph.add_edge(1,3)
      iex> {ctx, graph2} = InContext.Context.view(graph, 2)
      iex> ctx.node
      2
      iex> InContext.Context.edge_list(ctx)
      { [{1, 2, 1.0}], [{2, 3, 1.0}] }
      iex> InContext.Graph.has_node?(graph, 2)
      :true
      iex> InContext.Graph.has_node?(graph2, 2)
      :false
  """
  @spec view(Graph.t(), node | nil) :: {Context.t(), Graph.t()} | nil
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
