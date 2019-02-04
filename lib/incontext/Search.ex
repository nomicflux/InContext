defmodule InContext.Search do
  alias InContext.Graph
  alias InContext.Graph.Edge
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
    search_ctx(graph, [from], to, &dfs_combiner/2)
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
    search_ctx(graph, [from], to, &bfs_combiner/2)
  end

  defp dfs_combiner(ctx, nodes) do
    ctx.out_edges |>
      MapSet.to_list() |>
      Enum.map(&Edge.to/1) |>
      Enum.concat(nodes)
  end

  defp bfs_combiner(ctx, nodes) do
    new_nodes = ctx.out_edges |>
      MapSet.to_list() |>
      Enum.map(&Edge.to/1)
    Enum.concat(nodes, new_nodes)
  end

  defp search_ctx(graph, to_visit, to, combiner, visited \\ [])
  defp search_ctx(_graph, [], _to, _combiner, _visited), do: []
  defp search_ctx(_graph, [at | _rest], at, _combiner, visited) do
    Enum.reverse([at | visited])
  end
  defp search_ctx(graph, [from | rest], to, combiner, visited) do
    case Context.view(graph, from) do
      {nil, _} ->
        search_ctx(graph, rest, to, combiner, visited)
      {ctx, new_graph} ->
        new_nodes = combiner.(ctx, rest)
        search_ctx(new_graph, new_nodes, to, combiner, [ctx.node | visited])
    end
  end
end
