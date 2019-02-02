defmodule InContext.Search do
  alias InContext.Graph
  alias InContext.Context

  @spec dfs(Graph.t(), node, node) :: list(node)
  def dfs(graph, from, to) do
    c = Context.view(graph, from)
    search_ctx(c, [], to, &dfs_combiner/2, [])
  end

  @spec bfs(Graph.t(), node, node) :: list(node)
  def bfs(graph, from, to) do
    c = Context.view(graph, from)
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

  defp search_ctx({%Context{node: node}, _}, _, node, _, visited), do: Enum.reverse([node | visited])
  defp search_ctx({ctx, g}, to_visit, to, combiner, visited) do
    new_edges = combiner.(ctx, to_visit)
    case new_edges do
      [ next | rest ] ->
        search_ctx(Context.view(g, next.to), rest, to, combiner, [ctx.node | visited])
      [] ->
        []
    end
  end
end
