defmodule InContext.Search do
  alias InContext.Graph
  alias InContext.Context

  @moduledoc """
  Searching Algorithms using Graph Contexts

  @todo: Break out Combiners into their own module, to allow for different data structures for holding edges (queues for breadth-first search, priority queues for Dijkstra's, etc.)
  """

  @type node_id :: term

  @doc """
  Depth-first search of a graph, returning nodes visited.

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

      iex> use InContext
      iex> graph = Graph.tree_graph(4)
      iex> Search.dfs(graph, 0, 3)
      [0, 1, 3]
      iex> Search.dfs(graph, 0, 2)
      [0, 1, 3, 7, 8, 4, 9, 10, 2]
      iex> Search.dfs(graph, 1, 2)
      []
      iex> Search.dfs(graph, 0, 100)
      []
  """
  @spec dfs(Graph.t(), node_id, node_id) :: [node_id]
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

      iex> use InContext
      iex> graph = Graph.tree_graph(4)
      iex> Search.bfs(graph, 0, 3)
      [0, 1, 2, 3]
      iex> Search.bfs(graph, 0, 2)
      [0, 1, 2]
      iex> Search.bfs(graph, 1, 2)
      []
      iex> Search.bfs(graph, 0, 100)
      []
  """
  @spec bfs(Graph.t(), node_id, node_id) :: [node_id]
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

  defp search_ctx({%Context{node: node}, _}, _, node, _, visited) do
    Enum.reverse([node | visited])
  end
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
