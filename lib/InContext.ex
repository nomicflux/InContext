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

  To create a graph with edges from 1 to 2, 2 to 3, and 1 to 3:

      iex> use InContext
      iex> g = graph do
      ...>   1 ~> 2 ~> 3 <~ 1
      ...> end

  For a graph with an edge from 1 to 2 and 2 back to 1, and from 4 to 5 and 6 to 5:

      iex> use InContext
      iex> g = graph do
      ...>   1 <~> 2
      ...>   4 ~> 5 <~ 6
      ...> end
  """
  defmacro graph(do: graph_block) do
    edges = graph_block |>
      get_lines() |>
      Enum.map(&make_edges/1) |>
      Enum.map( fn {l, _} -> l end) |>
      Enum.concat
    quote do
      unquote(Macro.escape(edges)) |>
        Enum.reduce(InContext.Graph.new,
          fn ({f,t,w}, g) ->
            InContext.Graph.add_edge(g, f, t, w)
          end)
    end
  end

  defp get_lines({:__block__, _, graph_lines}), do: graph_lines
  defp get_lines(line), do: [line]

  defp make_edges({:~>, _, [edges, to]}) when is_tuple(edges) do
    {triples, next} = make_edges(edges)
    {[{next, to, 1.0} | triples], to}
  end
  defp make_edges({:<~, _, [edges, from]}) when is_tuple(edges) do
    {triples, next} = make_edges(edges)
    {[{from, next, 1.0} | triples], from}
  end
  defp make_edges({:<~>, _, [edges, from]}) when is_tuple(edges) do
    {triples, next} = make_edges(edges)
    {[{from, next, 1.0}, {next, from, 1.0} | triples], from}
  end
  defp make_edges({:~>, _, [from, to]}), do: {[{from, to, 1.0}], to}
  defp make_edges({:<~, _, [to, from]}), do: {[{from, to, 1.0}], from}
  defp make_edges({:<~>, _, [from, to]}), do: {[{to, from, 1.0}, {from, to, 1.0}], to}
end
