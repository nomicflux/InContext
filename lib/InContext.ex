defmodule InContext do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      alias InContext.Graph, as: Graph
      alias InContext.Graph.Edge, as: Edge
      alias InContext.Context, as: Context
      alias InContext.Search, as: Search

      import Graph, only: [{:~>, 2}, {:<~, 2}, {:<~>, 2}, {:~>>, 2}]
    end
  end
end
