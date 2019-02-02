defmodule Graph.Search do
  alias Graph.Context

  @spec dfs(%Graph{}, non_neg_integer, non_neg_integer) :: list(non_neg_integer)
  def dfs(graph, from, to) do
    c = Context.from_graph(graph, from)
    search_ctx(c, [], to, &dfs_combiner/2, [])
  end

  @spec bfs(%Graph{}, non_neg_integer, non_neg_integer) :: list(non_neg_integer)
  def bfs(graph, from, to) do
    c = Context.from_graph(graph, from)
    search_ctx(c, [], to, &bfs_combiner/2, [])
  end

  defp dfs_combiner(ctx, edges) do
    ctx.out_edges |>
      MapSet.to_list() |>
      Enum.concat(edges)
  end

  defp bfs_combiner(ctx, edges) do
    new_edges = ctx.out_edges |>
      MapSet.to_list()
    Enum.concat(edges, new_edges)
  end

  defp search_ctx(nil, _, _, _, _), do: []
  defp search_ctx({%Context{node: node}, _}, _, node, _, visited), do: Enum.reverse([node | visited])
  defp search_ctx({ctx, g}, to_visit, to, combiner, visited) do
    new_edges = combiner.(ctx, to_visit)
    case new_edges do
      [ next | rest ] ->
        search_ctx(Context.from_graph(g, next.to), rest, to, combiner, [ctx.node | visited])
      [] ->
        []
    end
  end
end
