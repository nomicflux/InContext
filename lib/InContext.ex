defmodule InContext do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      alias InContext.Graph, as: Graph
      alias InContext.Context, as: Context
      alias InContext.Search, as: Search
    end
  end

  @doc """
  Graph construction macro.

  ## Example

  To create a graph with edges from 1 to 2, 2 to 3 (with weight 0.5), and 1 to 3 (with weight 0.25):

      iex> use InContext
      iex> g = graph do
      ...>   1 -> 2
      ...>   2 -> 3 :: 0.5
      ...>   1 -> 3 :: 0.25
      ...> end
  """
  defmacro graph(do: graph_block) do
    edges = Enum.map(graph_block, &make_triple/1)
    quote do
      unquote(Macro.escape(edges)) |>
        Enum.reduce(InContext.Graph.new,
          fn ({f,t,w}, g) ->
            InContext.Graph.add_edge(g, f, t, w)
          end)
    end
  end

  defp make_triple({:->, _, [[from], {:::, _, [to, weight]}]}), do: {from, to, weight}
  defp make_triple({:->, _, [[from], to]}), do: {from, to, 1.0}
end
