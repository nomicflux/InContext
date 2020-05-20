defmodule InContext.Search do
  alias InContext.Graph
  alias InContext.Graph.Edge
  alias InContext.Context

  @moduledoc """
  Searching Algorithms using Graph Contexts
  """

  @type node_id :: term

  @doc """
  Depth-first search of a graph, returning pairs of nodes visited with
  the node used to reach them.

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
      [{nil, 0}, {0, 1}, {1, 3}]
      iex> Search.dfs(graph, 0, 2)
      [{nil, 0}, {0, 1}, {1, 3}, {3, 7}, {3, 8}, {1, 4}, {4, 9}, {4, 10}, {0, 2}]
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
      [{nil, 0}, {0, 1}, {0, 2}, {1, 3}]
      iex> Search.bfs(graph, 0, 2)
      [{nil, 0}, {0, 1}, {0, 2}]
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
      Enum.map(fn edge -> {Edge.from(edge), Edge.to(edge)} end) |>
      Enum.concat(nodes)
  end

  defp bfs_combiner(ctx, nodes) do
    new_nodes = ctx.out_edges |>
      MapSet.to_list() |>
      Enum.map(fn edge -> {Edge.from(edge), Edge.to(edge)} end)
    Enum.concat(nodes, new_nodes)
  end

  # Defaults to make initial calls more ergonomic
  # Default tail-recursive `visited`, and no need to specificy `nil` as
  # from node for starting positions

  # Case when `start` is a list of nodes
  defp search_ctx(graph, [start], to, combiner) when is_list(start) do
    search_ctx(graph, Enum.map(start, fn x -> {nil, x} end), to, combiner, [])
  end
  # Case when `start` is a single node
  defp search_ctx(graph, [start], to, combiner) when not is_tuple(start) do
    search_ctx(graph, [{nil, start}], to, combiner, [])
  end

  defp search_ctx(_graph, [], _to, _combiner, _path), do: []
  defp search_ctx(_graph, [{_last, at}=pair | _rest], at, _combiner, path) do
    Enum.reverse([pair | path])
  end
  defp search_ctx(graph, [{_last, from}=pair | rest], to, combiner, path) do
    case Context.view(graph, from) do
      {nil, _} ->
        search_ctx(graph, rest, to, combiner, path)
      {ctx, new_graph} ->
        new_nodes = combiner.(ctx, rest)
        search_ctx(new_graph, new_nodes, to, combiner, [pair | path])
    end
  end
end
