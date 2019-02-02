defmodule InContext.Search do
  alias InContext.Graph
  alias InContext.Context

  @moduledoc """
  Searching Algorithms using Graph Contexts
  """

  @doc """
  Depth-first search of a graph, returning nodes visited.

  ## Examples

  For the following graph:
  ```
                  7
             3 ->
                  8
       1 ->
                  9
             4 ->
                  10
  0 ->

             5

       2 ->

             6
  ```

      iex> graph = InContext.Graph.tree_graph(4)
      iex> InContext.Search.dfs(graph, 0, 3)
      [0, 1, 3]
      iex> InContext.Search.dfs(graph, 0, 2)
      [0, 1, 3, 7, 8, 4, 9, 10, 2]
      iex> InContext.Search.dfs(graph, 1, 2)
      []
      iex> InContext.Search.dfs(graph, 0, 100)
      []
  """
  @spec dfs(Graph.t(), node, node) :: list(node)
  def dfs(graph, from, to) do
    c = Context.view(graph, from)
    search_ctx(c, [], to, &dfs_combiner/2, [])
  end

  @doc """
  Breadth-first search of a graph, returning nodes visited.

  ## Examples

  For the following graph:
  ```
  0 -> [1 -> [3 -> [7,
                    8],
              4 -> [9,
                    10]],
        2 -> [5,
              6]]
  ```

      iex> graph = InContext.Graph.tree_graph(4)
      iex> InContext.Search.bfs(graph, 0, 3)
      [0, 1, 2, 3]
      iex> InContext.Search.bfs(graph, 0, 2)
      [0, 1, 2]
      iex> InContext.Search.bfs(graph, 1, 2)
      []
      iex> InContext.Search.bfs(graph, 0, 100)
      []
  """
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
