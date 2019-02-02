defmodule InContext.Context do
  alias __MODULE__
  alias InContext.Graph

  @moduledoc """
  Contextual Views on Graphs
  """

  @enforce_keys [:node]
  defstruct in_edges: MapSet.new, node: nil, out_edges: MapSet.new

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

  defp partition_map(map, node) do
    case Map.fetch(map, node) do
      {:ok, result} -> { result, Map.delete(map, node) }
      :error -> { MapSet.new, map }
    end
  end
end
